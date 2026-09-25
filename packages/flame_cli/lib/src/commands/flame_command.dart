import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/vm_service_uri_file.dart';

/// A command that talks to a running game.
///
/// The game is found through the `--uri` option, or if that isn't given,
/// through the file that `flame run` writes the URI of the game to.
abstract class FlameCommand extends Command<int> {
  FlameCommand(this.out, this.workingDirectory) {
    argParser.addOption(
      'uri',
      abbr: 'u',
      help:
          'The Dart VM Service URI of the running game, as printed by '
          '`flutter run`. Not needed if the game was started with '
          '`flame run`.',
    );
  }

  final StringSink out;
  final Directory workingDirectory;

  /// Validates the options, before a connection to the game is made.
  void validate() {}

  /// Runs the command with a [connection] to the game.
  Future<int> runWithConnection(FlameConnection connection);

  @override
  Future<int> run() async {
    validate();
    final connection = await _connect();
    try {
      return await runWithConnection(connection);
    } finally {
      await connection.dispose();
    }
  }

  Future<FlameConnection> _connect() async {
    final uri = argResults!.option('uri');
    if (uri != null) {
      return FlameConnection.connect(uri);
    }

    final file = findVmServiceUriFile(workingDirectory);
    if (file == null) {
      throw const FlameCliException(
        'No running game was found. Start the game with `flame run`, or pass '
        'the Dart VM Service URI of the game with --uri.',
        exitCode: ExitCodes.unavailable,
      );
    }

    try {
      return await FlameConnection.connect(file.readAsStringSync());
    } on FlameCliException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FlameCliException(
          '${error.message}\nThe URI was read from ${file.path}, the game '
          'might have been stopped.',
          exitCode: error.exitCode,
        ),
        stackTrace,
      );
    }
  }
}
