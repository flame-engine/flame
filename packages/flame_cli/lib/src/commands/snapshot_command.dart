import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/flame_connection.dart';

/// Renders the whole game, or a single component, to a PNG image.
class SnapshotCommand extends FlameCommand {
  SnapshotCommand(super.out, super.workingDirectory) {
    argParser
      ..addOption(
        'output',
        abbr: 'o',
        help: 'The file that the PNG image is written to.',
        defaultsTo: 'flame_snapshot.png',
      )
      ..addOption(
        'component',
        abbr: 'c',
        help:
            'The id of a single component to render instead of the whole '
            'game. Use the tree command to list the ids.',
      )
      ..addOption(
        'pixel-ratio',
        abbr: 'p',
        help: 'The pixel ratio that the whole game is rendered with.',
        defaultsTo: '1',
      );
  }

  @override
  String get name => 'snapshot';

  @override
  String get description =>
      'Render the game, or a single component, to a PNG image.';

  late double _pixelRatio;

  @override
  void validate() {
    final pixelRatio = double.tryParse(argResults!.option('pixel-ratio')!);
    if (pixelRatio == null || pixelRatio <= 0) {
      throw UsageException(
        '--pixel-ratio has to be a positive number.',
        usage,
      );
    }
    _pixelRatio = pixelRatio;
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    final componentId = argResults!.option('component');
    final response = componentId == null
        ? await connection.call(
            'getGameSnapshot',
            args: {'pixelRatio': _pixelRatio.toString()},
          )
        : await connection.call(
            'getComponentSnapshot',
            args: {'id': componentId},
          );

    final snapshot = response['snapshot'] as String? ?? '';
    if (snapshot.isEmpty) {
      throw FlameCliException(
        'No component with the id $componentId was found.',
        exitCode: ExitCodes.data,
      );
    }

    final file = File(argResults!.option('output')!);
    await file.writeAsBytes(base64Decode(snapshot));
    out.writeln(file.absolute.path);
    return ExitCodes.success;
  }
}
