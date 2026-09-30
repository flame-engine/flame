import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flame_cli/src/project_files.dart';

/// The request that the `reload` and `restart` commands send to `flame run`,
/// as one line on the control port.
enum RunRequest {
  reload('r'),
  restart('R');

  const RunRequest(this.key);

  /// The key that `flutter run` expects for the request.
  final String key;
}

/// Manages a `flutter run` [process] that was started by `flame run`.
///
/// It mirrors the output of the process to the terminal and to the log file
/// of the project, forwards the [input] of the terminal to the process, and
/// accepts [RunRequest]s on a loopback port that is written to the control
/// port file of the project. A request presses the corresponding key in
/// `flutter run` and responds with the line that `flutter run` prints when it
/// is done, as JSON with `ok`, `message` and `output` fields.
///
/// Several games can run from the same project at once, and the commands go
/// to the one that was started last. A controller owns the files of the
/// project as long as the control port file holds its port. When a newer
/// `flame run` takes them over, the controller stops writing to the log and
/// leaves the files alone when it exits, and when the newer run stops it
/// takes the files back.
class RunController {
  RunController({
    required this.process,
    required this.projectDirectory,
    this.input,
    StringSink? out,
    StringSink? err,
    this.responseTimeout = const Duration(minutes: 2),
    this.ownershipCheckInterval = const Duration(seconds: 1),
  }) : _out = out ?? stdout,
       _err = err ?? stderr;

  final Process process;
  final Directory projectDirectory;
  final Stream<List<int>>? input;
  final Duration responseTimeout;

  /// How often the control port file is checked to find out whether a newer
  /// `flame run` has taken over the project, or has stopped again.
  final Duration ownershipCheckInterval;

  final StringSink _out;
  final StringSink _err;

  final _lines = StreamController<String>.broadcast();
  Future<void> _requests = Future.value();
  bool _exited = false;
  bool _ownsFiles = true;
  IOSink? _log;
  String? _vmServiceUri;
  late final ServerSocket _server;

  static final _resultLine = RegExp(
    r'^(Reloaded \d+ (of \d+ )?(library|libraries)|Restarted application|'
    'Reload rejected|Hot reload was rejected|Try again after fixing)',
  );

  File get _controlPortFile =>
      projectFile(projectDirectory, controlPortFileName);
  File get _vmServiceUriFile =>
      projectFile(projectDirectory, vmServiceUriFileName);
  File get _logFile => projectFile(projectDirectory, logFileName);

  /// Runs until the process exits, and returns its exit code.
  Future<int> run() async {
    _logFile.createSync(recursive: true);
    _log = _logFile.openWrite();

    final subscriptions = <StreamSubscription<Object?>>[
      _mirror(process.stdout, _out),
      _mirror(process.stderr, _err),
      if (input != null) input!.listen(_forwardInput, onError: (_) {}),
    ];

    _server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    _controlPortFile.writeAsStringSync(_server.port.toString());
    _server.listen(_handleConnection);
    _out.writeln(
      'flame run: the reload and restart commands reach this game on port '
      '${_server.port}.',
    );
    final ownershipTimer = Timer.periodic(
      ownershipCheckInterval,
      (_) => _checkOwnership(),
    );

    try {
      return await process.exitCode;
    } finally {
      _exited = true;
      ownershipTimer.cancel();
      await _server.close();
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      await _lines.close();
      await _log?.close();
      if (_ownsFiles) {
        for (final file in [_controlPortFile, _vmServiceUriFile]) {
          if (file.existsSync()) {
            file.deleteSync();
          }
        }
      }
    }
  }

  void _checkOwnership() {
    final String? owner;
    try {
      owner = _controlPortFile.existsSync()
          ? _controlPortFile.readAsStringSync().trim()
          : null;
    } on FileSystemException {
      return;
    }

    if (owner == '${_server.port}') {
      _ownsFiles = true;
      if (_vmServiceUri == null && _vmServiceUriFile.existsSync()) {
        _vmServiceUri = _vmServiceUriFile.readAsStringSync();
      }
    } else if (owner == null) {
      // The newer flame run has stopped and removed the files, so this one
      // takes the project back.
      _controlPortFile.writeAsStringSync(_server.port.toString());
      final uri = _vmServiceUri;
      if (uri != null) {
        _vmServiceUriFile.writeAsStringSync(uri);
      }
      if (!_ownsFiles) {
        _ownsFiles = true;
        _log = _logFile.openWrite();
      }
    } else if (_ownsFiles) {
      _ownsFiles = false;
      _log?.close();
      _log = null;
    }
  }

  StreamSubscription<List<int>> _mirror(
    Stream<List<int>> stream,
    StringSink sink,
  ) {
    final broadcast = stream.asBroadcastStream();
    broadcast.transform(utf8.decoder).transform(const LineSplitter()).listen((
      line,
    ) {
      _log?.writeln(line);
      _lines.add(line);
    });
    return broadcast.listen((bytes) => sink.write(utf8.decode(bytes)));
  }

  void _forwardInput(List<int> bytes) {
    try {
      process.stdin.add(bytes);
    } on Object {
      // The process has stopped reading, which is reported by its exit code.
    }
  }

  void _handleConnection(Socket socket) {
    utf8.decoder
        .bind(socket)
        .transform(const LineSplitter())
        .first
        .then((line) async {
          final request = RunRequest.values
              .where((request) => request.name == line.trim())
              .firstOrNull;
          final response = request == null
              ? {'ok': false, 'message': 'Unknown request: $line'}
              : await _enqueue(request);
          socket.writeln(json.encode(response));
          await socket.flush();
          await socket.close();
        })
        .catchError((Object _) {
          socket.destroy();
        });
  }

  Future<Map<String, dynamic>> _enqueue(RunRequest request) {
    final result = _requests.then((_) => _perform(request));
    _requests = result.then((_) {}, onError: (Object _) {});
    return result;
  }

  Future<Map<String, dynamic>> _perform(RunRequest request) async {
    if (_exited) {
      return {'ok': false, 'message': 'flutter run has already stopped.'};
    }
    final output = <String>[];
    final done = Completer<String>();
    final subscription = _lines.stream.listen(
      (line) {
        output.add(line);
        if (!done.isCompleted && _resultLine.hasMatch(line)) {
          done.complete(line);
        }
      },
      onDone: () {
        if (!done.isCompleted) {
          done.complete('flutter run stopped before it reported the result.');
        }
      },
    );
    try {
      process.stdin.writeln(request.key);
      await process.stdin.flush();
      final message = await done.future.timeout(
        responseTimeout,
        onTimeout: () =>
            'flutter run did not report the result within '
            '${responseTimeout.inSeconds} seconds.',
      );
      final ok =
          message.startsWith('Reloaded') || message.startsWith('Restarted');
      return {'ok': ok, 'message': message, 'output': output};
    } finally {
      await subscription.cancel();
    }
  }
}
