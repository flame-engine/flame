import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/commands/run_command.dart';
import 'package:flame_cli/src/devtools_options.dart';
import 'package:flame_cli/src/flame_connection.dart';

/// Opens the Flutter DevTools for the running game with `dart devtools`,
/// where the Flame tab holds the Flame DevTools extension.
///
/// The game is found the same way as by the commands that talk to it, through
/// the `--uri` option or the file that `flame run` writes the URI to, and it
/// is checked to be reachable before the DevTools are started. The Flame
/// extension is enabled in the `devtools_options.yaml` of the project, so
/// that the DevTools show the Flame tab without asking.
class DevToolsCommand(
  final Directory workingDirectory, {
  ProcessStarter? startProcess,
  GameConnector? connect,

  /// Where the output of `dart devtools` is mirrored to, the standard output
  /// and error of this process by default.
  final StringSink? out,
  final StringSink? err,
}) extends Command<int> {
  this {
    argParser
      ..addOption(
        'uri',
        abbr: 'u',
        help:
            'The Dart VM Service URI of the running game, as printed by '
            '`flutter run`. Not needed if the game was started with '
            '`flame run`.',
      )
      ..addFlag(
        'launch-browser',
        defaultsTo: true,
        help:
            'Open the DevTools in the browser. With --no-launch-browser only '
            'the URL of the DevTools is printed, to open it in a browser of '
            'your choice.',
      );
  }

  final ProcessStarter _startProcess = startProcess ?? Process.start;
  final GameConnector _connect = connect ?? FlameConnection.connect;

  @override
  String get name => 'devtools';

  @override
  String get category => CommandCategories.launching;

  @override
  String get description =>
      'Open the Flutter DevTools for the running game in the browser, where '
      'the Flame tab holds the Flame DevTools extension. The command keeps '
      'serving the DevTools until it is stopped with Ctrl+C.';

  @override
  Future<int> run() async {
    final connection = await connectToGame(
      workingDirectory,
      uriOption: argResults!.option('uri'),
      connect: _connect,
    );
    final uri = connection.uri;
    await connection.dispose();

    final optionsFile = devToolsOptionsFile(workingDirectory);
    if (enableFlameExtension(optionsFile)) {
      (out ?? stdout).writeln(
        'Enabled the Flame DevTools extension in ${optionsFile.path}.',
      );
    }

    final process = await startDart(
      _startProcess,
      [
        'devtools',
        if (!argResults!.flag('launch-browser')) '--no-launch-browser',
        uri,
      ],
      workingDirectory: workingDirectory,
    );
    await forwardOutput(process, out ?? stdout, err ?? stderr);
    return await process.exitCode;
  }
}
