import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/vm_service_uri_file.dart';

/// Connects to the game at the given URI, as [FlameConnection.connect] does.
typedef GameConnector = Future<FlameConnection> Function(String uri);

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
    final connection = await connectToGame(
      workingDirectory,
      uriOption: argResults!.option('uri'),
    );
    try {
      return await runWithConnection(connection);
    } finally {
      await connection.dispose();
    }
  }
}

/// Connects to the running game, which is [uriOption] when it is given, and
/// otherwise the game that `flame run` started for the project that
/// [workingDirectory] is in.
///
/// Throws a [FlameCliException] when no running game is found or when it
/// cannot be reached, which says where the URI came from when it was read
/// from the file that `flame run` writes.
Future<FlameConnection> connectToGame(
  Directory workingDirectory, {
  String? uriOption,
  GameConnector connect = FlameConnection.connect,
}) async {
  final (:uri, :file) = findVmServiceUri(
    workingDirectory,
    uriOption: uriOption,
  );
  if (file == null) {
    return connect(uri);
  }

  try {
    return await connect(uri);
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
