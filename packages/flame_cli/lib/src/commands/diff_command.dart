import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/image_diff.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Compares two PNG images, for example two snapshots.
class DiffCommand extends Command<int> {
  DiffCommand(this.out, this.workingDirectory) {
    argParser
      ..addOption(
        'output',
        abbr: 'o',
        help:
            'Write an image that highlights the differing pixels in red on '
            'top of a dimmed version of the second image.',
      )
      ..addOption(
        'threshold',
        abbr: 't',
        help:
            'How much a color channel may differ (0 to 255) before a pixel '
            'counts as different.',
        defaultsTo: '0',
      )
      ..addFlag(
        'exit-code',
        negatable: false,
        help: 'Exit with 1 when the images differ, like `git diff`.',
      );
  }

  final StringSink out;
  final Directory workingDirectory;

  @override
  String get name => 'diff';

  @override
  String get description =>
      'Compare two PNG images and report how much and where they differ.';

  @override
  String get invocation => 'flame diff <before.png> <after.png>';

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    if (rest.length != 2) {
      throw UsageException('Pass two PNG files to compare.', usage);
    }
    final threshold = int.tryParse(argResults!.option('threshold')!);
    if (threshold == null || threshold < 0 || threshold > 255) {
      throw UsageException(
        '--threshold has to be an integer between 0 and 255.',
        usage,
      );
    }

    final before = _readImage(rest[0]);
    final after = _readImage(rest[1]);
    if (before.width != after.width || before.height != after.height) {
      throw FlameCliException(
        'The images have different sizes: ${before.width}x${before.height} '
        'and ${after.width}x${after.height}.',
        exitCode: ExitCodes.data,
      );
    }

    final result = diffImages(before, after, threshold: threshold);
    out.writeln(result.summary);

    final output = argResults!.option('output');
    if (output != null) {
      final file = File(p.join(workingDirectory.path, output));
      try {
        await file.writeAsBytes(img.encodePng(result.image));
      } on FileSystemException catch (error, stackTrace) {
        Error.throwWithStackTrace(
          FlameCliException(
            'Could not write the diff image to ${file.path}: '
            '${error.osError?.message ?? error.message}',
            exitCode: ExitCodes.cantCreate,
          ),
          stackTrace,
        );
      }
      out.writeln(file.absolute.path);
    }

    if (argResults!.flag('exit-code') && result.differingPixels > 0) {
      return 1;
    }
    return ExitCodes.success;
  }

  img.Image _readImage(String path) {
    final file = File(p.join(workingDirectory.path, path));
    final img.Image? image;
    try {
      image = img.decodePng(file.readAsBytesSync());
    } on FileSystemException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FlameCliException(
          'Could not read ${file.path}: '
          '${error.osError?.message ?? error.message}',
          exitCode: ExitCodes.data,
        ),
        stackTrace,
      );
    }
    if (image == null) {
      throw FlameCliException(
        '${file.path} is not a PNG image.',
        exitCode: ExitCodes.data,
      );
    }
    return image;
  }
}
