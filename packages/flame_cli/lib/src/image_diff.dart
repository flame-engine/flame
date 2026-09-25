import 'dart:math';

import 'package:image/image.dart' as img;

/// The result of comparing two images with [diffImages].
class ImageDiff {
  ImageDiff({
    required this.differingPixels,
    required this.totalPixels,
    required this.bounds,
    required this.image,
  });

  final int differingPixels;
  final int totalPixels;

  /// The smallest rectangle that contains all the differing pixels, as
  /// `(left, top, width, height)`, or null if the images are identical.
  final ({int left, int top, int width, int height})? bounds;

  /// The differing pixels in red on top of a dimmed version of the second
  /// image.
  final img.Image image;

  double get percentage => differingPixels / totalPixels * 100;

  /// A one line description of the difference.
  String get summary {
    final bounds = this.bounds;
    if (bounds == null) {
      return 'The images are identical.';
    }
    return '${percentage.toStringAsFixed(2)}% of the pixels differ '
        '($differingPixels of $totalPixels), within the rectangle '
        '${bounds.left},${bounds.top} of size '
        '${bounds.width}x${bounds.height}.';
  }
}

/// Compares [before] and [after], which have to have the same size.
///
/// A pixel counts as different when one of its color or alpha channels
/// differs by more than [threshold].
ImageDiff diffImages(img.Image before, img.Image after, {int threshold = 0}) {
  final image = img.Image(width: after.width, height: after.height);
  var differing = 0;
  var left = after.width;
  var top = after.height;
  var right = -1;
  var bottom = -1;

  for (var y = 0; y < after.height; y++) {
    for (var x = 0; x < after.width; x++) {
      final a = before.getPixel(x, y);
      final b = after.getPixel(x, y);
      final difference = [
        (a.r - b.r).abs(),
        (a.g - b.g).abs(),
        (a.b - b.b).abs(),
        (a.a - b.a).abs(),
      ].reduce(max);
      if (difference > threshold) {
        differing++;
        left = min(left, x);
        top = min(top, y);
        right = max(right, x);
        bottom = max(bottom, y);
        image.setPixelRgba(x, y, 255, 0, 0, 255);
      } else {
        final gray = (b.luminance * 0.3 + 80).round();
        image.setPixelRgba(x, y, gray, gray, gray, 255);
      }
    }
  }

  return ImageDiff(
    differingPixels: differing,
    totalPixels: after.width * after.height,
    bounds: differing == 0
        ? null
        : (
            left: left,
            top: top,
            width: right - left + 1,
            height: bottom - top + 1,
          ),
    image: image,
  );
}
