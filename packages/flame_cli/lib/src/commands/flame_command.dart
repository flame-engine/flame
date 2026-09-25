import 'package:args/command_runner.dart';
import 'package:flame_cli/src/flame_connection.dart';

/// A command that talks to a running game, which is found through the
/// `--uri` option that all these commands share.
abstract class FlameCommand extends Command<int> {
  FlameCommand(this.out) {
    argParser.addOption(
      'uri',
      abbr: 'u',
      help:
          'The Dart VM Service URI of the running game, as printed by '
          '`flutter run` (required).',
    );
  }

  final StringSink out;

  /// Validates the options, before a connection to the game is made.
  void validate() {}

  /// Runs the command with a [connection] to the game.
  Future<int> runWithConnection(FlameConnection connection);

  @override
  Future<int> run() async {
    final uri = argResults!.option('uri');
    if (uri == null) {
      throw UsageException('The --uri option is required.', usage);
    }
    validate();
    final connection = await FlameConnection.connect(uri);
    try {
      return await runWithConnection(connection);
    } finally {
      await connection.dispose();
    }
  }
}
