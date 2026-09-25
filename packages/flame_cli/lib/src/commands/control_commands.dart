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
  _RunRequestCommand(this.out, this.workingDirectory, {required this.request});

  final StringSink out;
  final Directory workingDirectory;
  final RunRequest request;

  @override
  Future<int> run() async {
    final response = await sendRunRequest(workingDirectory, request);
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
/// is in, and returns its response.
Future<Map<String, dynamic>> sendRunRequest(
  Directory workingDirectory,
  RunRequest request,
) async {
  final portFile = findProjectFile(workingDirectory, controlPortFileName);
  final port = portFile == null
      ? null
      : int.tryParse(portFile.readAsStringSync().trim());
  if (port == null) {
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
      port,
      timeout: const Duration(seconds: 5),
    );
  } on SocketException catch (error, stackTrace) {
    Error.throwWithStackTrace(
      FlameCliException(
        'Could not reach `flame run` on port $port, it might have stopped: '
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
