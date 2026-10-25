import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/commands/inspect_command.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/game_responses.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as p;

/// Renders the whole game, the world, or a single component, to a PNG image.
class SnapshotCommand(super.out, super.workingDirectory) extends FlameCommand {
  this {
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
      ..addFlag(
        'world',
        abbr: 'w',
        negatable: false,
        help:
            'Render the whole world directly instead of through the camera, '
            'which also shows the components that are off screen.',
      )
      ..addOption(
        'rect',
        abbr: 'r',
        help:
            'Render this part of the world, given as x,y,width,height in '
            'world coordinates, instead of the whole world.',
      )
      ..addOption(
        'pixel-ratio',
        abbr: 'p',
        help: 'The pixel ratio that the image is rendered with.',
        defaultsTo: '1',
      );
  }

  @override
  String get name => 'snapshot';

  @override
  String get category => CommandCategories.observing;

  @override
  String get description =>
      'Render the game, the world, or a single component, to a PNG image.';

  late double _pixelRatio;
  late int? _componentId;
  late WorldRect? _rect;

  @override
  void validate() {
    final pixelRatio = double.tryParse(argResults!.option('pixel-ratio')!);
    if (pixelRatio == null || !pixelRatio.isFinite || pixelRatio <= 0) {
      throw UsageException(
        '--pixel-ratio has to be a positive number.',
        usage,
      );
    }
    _pixelRatio = pixelRatio;
    _componentId = componentIdOption(this, 'component');

    _rect = null;
    final rect = argResults!.option('rect');
    if (rect != null) {
      final parts = rect.split(',').map(double.tryParse).toList();
      if (parts.length != 4 ||
          parts.any((p) => p == null || !p.isFinite) ||
          parts[2]! <= 0 ||
          parts[3]! <= 0) {
        throw UsageException(
          '--rect has to be four numbers x,y,width,height with a positive '
          'width and height.',
          usage,
        );
      }
      _rect = (x: parts[0]!, y: parts[1]!, width: parts[2]!, height: parts[3]!);
    }

    final world = argResults!.flag('world') || rect != null;
    if (world && _componentId != null) {
      throw UsageException(
        '--component renders a single component, it cannot be combined with '
        '--world or --rect.',
        usage,
      );
    }
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    final componentId = _componentId;
    final snapshot = componentId == null
        ? await connection.getGameSnapshot(
            pixelRatio: _pixelRatio,
            world: argResults!.flag('world'),
            rect: _rect,
          )
        : await connection.getComponentSnapshot(
            componentId,
            pixelRatio: _pixelRatio,
          );

    if (snapshot.bytes.isEmpty) {
      throw const FlameCliException(
        'The game returned an empty snapshot.',
        exitCode: ExitCode.data,
      );
    }

    final file = File(
      p.join(workingDirectory.path, argResults!.option('output')),
    );
    try {
      await file.writeAsBytes(snapshot.bytes);
    } on FileSystemException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FlameCliException(
          'Could not write the snapshot to ${file.path}: '
          '${error.osError?.message ?? error.message}',
          exitCode: ExitCode.cantCreate,
        ),
        stackTrace,
      );
    }
    out.writeln(file.absolute.path);
    return ExitCode.success.code;
  }
}
