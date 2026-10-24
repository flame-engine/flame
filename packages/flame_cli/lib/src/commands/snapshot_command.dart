import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/flame_connection.dart';
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
      )
      ..addOption(
        'max-size',
        abbr: 'm',
        help:
            'The maximum length in pixels of the longest side of the image. '
            'The pixel ratio is lowered to fit, keeping the aspect ratio.',
      )
      ..addFlag(
        'annotate',
        abbr: 'a',
        negatable: false,
        help:
            'Draw the box of every visible position component on the image, '
            'labeled with its id and type, and print the boxes.',
      )
      ..addOption(
        'filter',
        abbr: 'f',
        help:
            'Only annotate the components whose type matches this regular '
            'expression (case insensitive). Needs --annotate.',
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
  late int? _maxSize;

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

    final maxSize = argResults!.option('max-size');
    _maxSize = maxSize == null ? null : int.tryParse(maxSize);
    if (maxSize != null && (_maxSize == null || _maxSize! <= 0)) {
      throw UsageException('--max-size has to be a positive integer.', usage);
    }

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
    }

    final world = argResults!.flag('world') || rect != null;
    if (world && argResults!.option('component') != null) {
      throw UsageException(
        '--component renders a single component, it cannot be combined with '
        '--world or --rect.',
        usage,
      );
    }

    final filter = argResults!.option('filter');
    if (filter != null) {
      if (!argResults!.flag('annotate')) {
        throw UsageException(
          '--filter selects the components to annotate, so it needs '
          '--annotate.',
          usage,
        );
      }
      try {
        RegExp(filter, caseSensitive: false);
      } on FormatException catch (error, stackTrace) {
        Error.throwWithStackTrace(
          UsageException(
            '--filter is not a valid regular expression: ${error.message}',
            usage,
          ),
          stackTrace,
        );
      }
    }
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    final componentId = argResults!.option('component');
    final rect = argResults!.option('rect');
    final annotate = argResults!.flag('annotate');
    final filter = argResults!.option('filter');
    final maxSize = _maxSize;
    final options = {
      'pixelRatio': _pixelRatio.toString(),
      if (annotate) 'annotate': 'true',
      'annotationFilter': ?filter,
      if (maxSize != null) 'maxSize': maxSize.toString(),
    };
    final response = componentId == null
        ? await connection.call(
            'getGameSnapshot',
            args: {
              ...options,
              if (argResults!.flag('world')) 'world': 'true',
              'rect': ?rect,
            },
          )
        : await connection.call(
            'getComponentSnapshot',
            args: {'id': componentId, ...options},
          );

    final annotations = response['annotations'] as List?;
    final pixelRatio = response['pixelRatio'] as num?;
    final unsupported = [
      if (annotate && annotations == null) '--annotate',
      if (maxSize != null && pixelRatio == null) '--max-size',
    ];
    if (unsupported.isNotEmpty) {
      throw FlameCliException(
        'The running game does not support ${unsupported.join(' and ')}, '
        'update Flame to the latest version.',
        exitCode: ExitCode.unavailable,
      );
    }

    final snapshot = response['snapshot'] as String? ?? '';
    if (snapshot.isEmpty) {
      throw const FlameCliException(
        'The game returned an empty snapshot.',
        exitCode: ExitCode.data,
      );
    }

    final file = File(
      p.join(workingDirectory.path, argResults!.option('output')),
    );
    try {
      await file.writeAsBytes(base64Decode(snapshot));
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

    if (annotations != null) {
      out.write(formatSnapshotAnnotations(annotations));
    }
    if (pixelRatio != null && (pixelRatio - _pixelRatio).abs() > 1e-9) {
      out.writeln(
        'The image was scaled down to ${response['width']}x'
        '${response['height']} pixels to fit --max-size, a pixel ratio of '
        '${_formatPixelRatio(pixelRatio)}.',
      );
    }
    out.writeln(file.absolute.path);
    return ExitCode.success.code;
  }

  static String _formatPixelRatio(num pixelRatio) {
    return pixelRatio
        .toStringAsFixed(4)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

/// Formats the annotations returned by the snapshot service extensions with
/// one component per line, in the same style as the component tree, with the
/// box of the component in the pixel coordinates of the image as
/// `x,y,width,height`.
String formatSnapshotAnnotations(List<dynamic> annotations) {
  if (annotations.isEmpty) {
    return 'No visible components were annotated.\n';
  }
  final buffer = StringBuffer();
  for (final annotation in annotations.cast<Map<String, dynamic>>()) {
    final box = (annotation['box'] as List)
        .map((value) => (value as num).round())
        .join(',');
    buffer.writeln(
      '${annotation['name']} (id: ${annotation['id']}) box $box',
    );
  }
  return buffer.toString();
}
