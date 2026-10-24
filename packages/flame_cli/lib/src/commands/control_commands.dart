import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/json_output.dart';
import 'package:flame_cli/src/merge/merging_reload.dart';
import 'package:flame_cli/src/project_files.dart';
import 'package:flame_cli/src/run_controller.dart';
import 'package:io/io.dart';

/// Hot reloads the game through `flame run`, and with `--merge` also applies
/// the changes of the code that sets up the components, see [mergingReload].
class ReloadCommand(super.out, super.workingDirectory)
    extends _RunRequestCommand {
  this : super(request: RunRequest.reload) {
    argParser
      ..addFlag(
        'merge',
        abbr: 'm',
        negatable: false,
        help:
            'Also apply the changes to constructors and onLoad methods to '
            'the live components, keeping their state. The game has to have '
            'a constructor that takes no arguments.',
      )
      ..addFlag(
        'keep-runtime',
        negatable: false,
        help:
            'With --merge, keep a value that changed while the game was '
            'running when the code changed it too, instead of replacing it '
            'with the value from the code.',
      )
      ..addOption(
        'uri',
        abbr: 'u',
        help:
            'With --merge, the Dart VM Service URI of the running game. Not '
            'needed if the game was started with `flame run`.',
      );
  }

  @override
  String get name => 'reload';

  @override
  String get description =>
      'Hot reload the game, which has to have been started with `flame run`.';

  @override
  Future<int> run() async {
    final arguments = argResults!;
    if (!arguments.flag('merge')) {
      if (arguments.flag('keep-runtime')) {
        throw UsageException('--keep-runtime needs --merge.', usage);
      }
      return await super.run();
    }
    final port = parsePortOption(arguments, usage);
    final connection = await connectToGame(
      workingDirectory,
      uriOption: arguments.option('uri'),
    );
    try {
      final ok = await mergingReload(
        connection: connection,
        reload: () => sendRunRequest(workingDirectory, request, port: port),
        out: out,
        keepRuntime: arguments.flag('keep-runtime'),
      );
      return (ok ? ExitCode.success : ExitCode.software).code;
    } finally {
      await connection.dispose();
    }
  }
}

/// Hot restarts the game through `flame run`.
class RestartCommand(super.out, super.workingDirectory)
    extends _RunRequestCommand {
  this : super(request: RunRequest.restart);

  @override
  String get name => 'restart';

  @override
  String get description =>
      'Hot restart the game, which has to have been started with `flame run`.';
}

/// Stops the game through `flame run`.
class StopCommand(super.out, super.workingDirectory)
    extends _RunRequestCommand {
  this : super(request: RunRequest.stop);

  @override
  String get name => 'stop';

  @override
  String get description =>
      'Stop the game, which has to have been started with `flame run`, and '
      'wait until it has exited.';
}

abstract class _RunRequestCommand(
  @override final StringSink out,
  final Directory workingDirectory, {
  required final RunRequest request,
}) extends Command<int> with JsonOutput {
  this {
    addPortOption(argParser);
    addJsonFlag(argParser);
  }

  @override
  String get category => CommandCategories.launching;

  @override
  Future<int> run() async {
    final port = parsePortOption(argResults!, usage);
    final response = await sendRunRequest(
      workingDirectory,
      request,
      port: port,
    );
    final RunResponse(:ok, :message) = response;
    if (jsonOutput) {
      out.writeln(toJsonOutput(response.toJson()));
      return (ok ? ExitCode.success : ExitCode.software).code;
    }
    final output = ok ? const <String>[] : response.output;
    for (final line in output) {
      out.writeln(line);
    }
    if (output.isEmpty || output.last != message) {
      out.writeln(message);
    }
    return (ok ? ExitCode.success : ExitCode.software).code;
  }
}

/// Adds the `--port` option, which chooses the `flame run` that a request is
/// sent to.
void addPortOption(ArgParser argParser) {
  argParser.addOption(
    'port',
    abbr: 'p',
    help:
        'The control port of the `flame run` to send the request to, which '
        'it prints when it starts. Only needed when several games were '
        'started from the same project and the request is for one that '
        'was not started last.',
  );
}

/// Parses the `--port` option that [addPortOption] added, and throws a
/// [UsageException] with [usage] when it is not a port number.
int? parsePortOption(ArgResults argResults, String usage) {
  final portOption = argResults.option('port');
  final port = portOption == null ? null : int.tryParse(portOption);
  if (portOption != null && (port == null || port <= 0 || port > 65535)) {
    throw UsageException(
      '--port has to be an integer between 1 and 65535.',
      usage,
    );
  }
  return port;
}

/// Finds the control port of the `flame run` of the project that
/// [workingDirectory] is in.
///
/// Returns null if no game that was started with `flame run` is found.
int? findControlPort(Directory workingDirectory) {
  final portFile = findProjectFile(workingDirectory, controlPortFileName);
  if (portFile == null) {
    return null;
  }
  try {
    return int.tryParse(portFile.readAsStringSync().trim());
  } on FileSystemException {
    return null;
  }
}

/// Sends [request] to the `flame run` of the project that [workingDirectory]
/// is in, or to the one listening on [port] if given, and returns its
/// response.
Future<RunResponse> sendRunRequest(
  Directory workingDirectory,
  RunRequest request, {
  int? port,
}) async {
  final targetPort = port ?? findControlPort(workingDirectory);
  if (targetPort == null) {
    throw const FlameCliException(
      'No game that was started with `flame run` was found, so there is '
      'nothing to send the request to.',
      exitCode: ExitCode.unavailable,
    );
  }

  final Socket socket;
  try {
    socket = await Socket.connect(
      InternetAddress.loopbackIPv4,
      targetPort,
      timeout: const Duration(seconds: 5),
    );
  } on SocketException catch (error, stackTrace) {
    Error.throwWithStackTrace(
      FlameCliException(
        'Could not reach `flame run` on port $targetPort, it might have '
        'stopped: '
        '${error.message}',
        exitCode: ExitCode.unavailable,
      ),
      stackTrace,
    );
  }

  try {
    socket.writeln(request.name);
    await socket.flush();
    final line = await utf8.decoder
        .bind(socket)
        .transform(const LineSplitter())
        .first;
    return RunResponse.fromJson(json.decode(line) as Map<String, dynamic>);
  } on Object catch (error, stackTrace) {
    Error.throwWithStackTrace(
      FlameCliException(
        '`flame run` did not respond to the request: $error',
        exitCode: ExitCode.unavailable,
      ),
      stackTrace,
    );
  } finally {
    socket.destroy();
  }
}
