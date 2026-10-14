import 'dart:typed_data';

import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/alpha_contours.dart';

extension Uint8ListExtension on Uint8List {
  /// Returns the outlines of the parts of these pixels that are not
  /// transparent, as the closed contours of a [Path].
  ///
  /// The pixels are in the RGBA format, [width] by [height], as in
  /// [ImageExtension.fromPixels]. See [ImageExtension.contour] for the
  /// [region], [size] and [alphaThreshold] parameters.
  Path contour(
    int width,
    int height, {
    Rect? region,
    Vector2? size,
    double alphaThreshold = 0.5,
  }) {
    assert(length == width * height * 4);
    assert(
      alphaThreshold > 0 && alphaThreshold <= 1,
      'The alpha threshold has to be in (0, 1]: $alphaThreshold',
    );
    final left = region?.left.round() ?? 0;
    final top = region?.top.round() ?? 0;
    final right = region?.right.round() ?? width;
    final bottom = region?.bottom.round() ?? height;
    // A region that is clamped to the image would move and stretch the
    // contours, relative to the region that was asked for.
    assert(
      left >= 0 && top >= 0 && right <= width && bottom <= height,
      'The region $region is not within the image of $width x $height',
    );
    assert(right >= left && bottom >= top, 'The region $region is inverted');
    final columns = right - left;
    final rows = bottom - top;
    return traceAlphaContours(
      this,
      width: width,
      left: left,
      top: top,
      columns: columns,
      rows: rows,
      threshold: alphaThreshold,
      scaleX: size == null || columns == 0 ? 1 : size.x / columns,
      scaleY: size == null || rows == 0 ? 1 : size.y / rows,
    );
  }
}
