import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/project_files.dart';
import 'package:flame_cli/src/run_controller.dart';

/// Hot reloads the game through `flame run`.
class ReloadCommand extends _RunRequestCommand {
  ReloadCommand(super.out, super.workingDirectory)
    : super(request: RunRequest.reload);

  @override
  String get name => 'reload';

  @override
  String get description =>
      'Hot reload the game, which has to have been started with `flame run`.';
}

/// Hot restarts the game through `flame run`.
class RestartCommand extends _RunRequestCommand {
  RestartCommand(super.out, super.workingDirectory)
    : super(request: RunRequest.restart);

  @override
  String get name => 'restart';

  @override
  String get description =>
      'Hot restart the game, which has to have been started with `flame run`.';
}

abstract class _RunRequestCommand extends Command<int> {
  _RunRequestCommand(this.out, this.workingDirectory, {required this.request}) {
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

  final StringSink out;
  final Directory workingDirectory;
  final RunRequest request;

  @override
  Future<int> run() async {
    final portOption = argResults!.option('port');
    final port = portOption == null ? null : int.tryParse(portOption);
    if (portOption != null && (port == null || port <= 0)) {
      throw UsageException('--port has to be a positive integer.', usage);
    }
    final response = await sendRunRequest(
      workingDirectory,
      request,
      port: port,
    );
    final ok = response['ok'] == true;
    final message = response['message'];
    final output = ok ? const [] : (response['output'] as List?) ?? const [];
    for (final line in output) {
      out.writeln(line);
    }
    if (output.isEmpty || output.last != message) {
      out.writeln(message);
    }
    return ok ? ExitCodes.success : ExitCodes.software;
  }
}

/// Sends [request] to the `flame run` of the project that [workingDirectory]
/// is in, or to the one listening on [port] if given, and returns its
/// response.
Future<Map<String, dynamic>> sendRunRequest(
  Directory workingDirectory,
  RunRequest request, {
  int? port,
}) async {
  var targetPort = port;
  if (targetPort == null) {
    final portFile = findProjectFile(workingDirectory, controlPortFileName);
    targetPort = portFile == null
        ? null
        : int.tryParse(portFile.readAsStringSync().trim());
  }
  if (targetPort == null) {
    throw const FlameCliException(
      'No game that was started with `flame run` was found, so there is '
      'nothing to send the request to.',
      exitCode: ExitCodes.unavailable,
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
        exitCode: ExitCodes.unavailable,
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
    return json.decode(line) as Map<String, dynamic>;
  } on Object catch (error, stackTrace) {
    Error.throwWithStackTrace(
      FlameCliException(
        '`flame run` did not respond to the request: $error',
        exitCode: ExitCodes.unavailable,
      ),
      stackTrace,
    );
  } finally {
    socket.destroy();
  }
}
