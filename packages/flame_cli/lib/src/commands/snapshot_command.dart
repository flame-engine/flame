import 'dart:io';
import 'dart:typed_data';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/commands/inspect_command.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/game_responses.dart';
import 'package:flame_cli/src/json_output.dart';
import 'package:image/image.dart' as img;
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

    final maxSize = argResults!.option('max-size');
    _maxSize = maxSize == null ? null : int.tryParse(maxSize);
    if (maxSize != null && (_maxSize == null || _maxSize! <= 0)) {
      throw UsageException('--max-size has to be a positive integer.', usage);
    }

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
    final componentId = _componentId;
    final maxSize = _maxSize;
    final options = SnapshotOptions(
      annotate: argResults!.flag('annotate'),
      annotationFilter: argResults!.option('filter'),
      maxSize: maxSize,
    );
    final snapshot = componentId == null
        ? await connection.getGameSnapshot(
            pixelRatio: _pixelRatio,
            world: argResults!.flag('world'),
            rect: _rect,
            options: options,
          )
        : await connection.getComponentSnapshot(
            componentId,
            pixelRatio: _pixelRatio,
            options: options,
          );

    final Snapshot(:annotations, :pixelRatio) = snapshot;
    final unsupported = [
      if (options.annotate && annotations == null) '--annotate',
      if (maxSize != null && pixelRatio == null) '--max-size',
    ];
    if (unsupported.isNotEmpty) {
      throw FlameCliException(
        'The running game does not support ${unsupported.join(' and ')}, '
        'update Flame to the latest version.',
        exitCode: ExitCode.unavailable,
      );
    }

    if (snapshot.bytes.isEmpty) {
      throw const FlameCliException(
        'The game returned an empty snapshot.',
        exitCode: ExitCode.data,
      );
    }

    final file = File(
      p.join(workingDirectory.path, argResults!.option('output')),
    );
    final bytes = snapshot.bytes;
    try {
      await file.writeAsBytes(bytes);
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

    final path = file.absolute.path;
    if (jsonOutput) {
      final info = _pngInfo(bytes);
      out.writeln(
        toJsonOutput({
          'path': path,
          'width': info?.width,
          'height': info?.height,
          'pixelRatio': pixelRatio ?? _pixelRatio,
          'bytes': bytes.length,
          if (annotations != null)
            'annotations': [
              for (final annotation in annotations) annotation.toJson(),
            ],
        }),
      );
      return ExitCode.success.code;
    }

    if (annotations != null) {
      out.write(formatSnapshotAnnotations(annotations));
    }
    if (pixelRatio != null && (pixelRatio - _pixelRatio).abs() > 1e-9) {
      out.writeln(
        'The image was scaled down to ${snapshot.width}x'
        '${snapshot.height} pixels to fit --max-size, a pixel ratio of '
        '${_formatPixelRatio(pixelRatio)}.',
      );
    }
    out.writeln(path);
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
String formatSnapshotAnnotations(List<SnapshotAnnotation> annotations) {
  if (annotations.isEmpty) {
    return 'No visible components were annotated.\n';
  }
  final buffer = StringBuffer();
  for (final SnapshotAnnotation(:id, :name, :box) in annotations) {
    final pixels = [
      box.x,
      box.y,
      box.width,
      box.height,
    ].map((value) => value.round()).join(',');
    buffer.writeln('$name (id: $id) box $pixels');
  }
  return buffer.toString();
}

img.DecodeInfo? _pngInfo(Uint8List bytes) {
  try {
    return img.PngDecoder().startDecode(bytes);
  } on img.ImageException {
    return null;
  }
}
