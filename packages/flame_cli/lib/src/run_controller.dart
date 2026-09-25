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
class RunController {
  RunController({
    required this.process,
    required this.projectDirectory,
    this.input,
    StringSink? out,
    StringSink? err,
    this.responseTimeout = const Duration(minutes: 2),
  }) : _out = out ?? stdout,
       _err = err ?? stderr;

  final Process process;
  final Directory projectDirectory;
  final Stream<List<int>>? input;
  final Duration responseTimeout;
  final StringSink _out;
  final StringSink _err;

  final _lines = StreamController<String>.broadcast();
  Future<void> _requests = Future.value();
  bool _exited = false;

  static final _resultLine = RegExp(
    r'^(Reloaded \d+ (of \d+ )?(library|libraries)|Restarted application|'
    'Reload rejected|Hot reload was rejected|Try again after fixing)',
  );

  /// Runs until the process exits, and returns its exit code.
  Future<int> run() async {
    final logFile = projectFile(projectDirectory, logFileName)
      ..createSync(recursive: true);
    final log = logFile.openWrite();
    final controlPortFile = projectFile(projectDirectory, controlPortFileName);

    final subscriptions = <StreamSubscription<Object?>>[
      _mirror(process.stdout, _out, log),
      _mirror(process.stderr, _err, log),
      if (input != null) input!.listen(_forwardInput, onError: (_) {}),
    ];

    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    controlPortFile.writeAsStringSync(server.port.toString());
    server.listen(_handleConnection);

    try {
      return await process.exitCode;
    } finally {
      _exited = true;
      await server.close();
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      await _lines.close();
      await log.close();
      for (final name in [controlPortFileName, vmServiceUriFileName]) {
        final file = projectFile(projectDirectory, name);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
    }
  }

  StreamSubscription<List<int>> _mirror(
    Stream<List<int>> stream,
    StringSink sink,
    IOSink log,
  ) {
    final broadcast = stream.asBroadcastStream();
    broadcast.transform(utf8.decoder).transform(const LineSplitter()).listen((
      line,
    ) {
      log.writeln(line);
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
