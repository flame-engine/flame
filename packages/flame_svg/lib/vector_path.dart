import 'dart:ui' as ui;

import 'package:flame_svg/vector_paint.dart';
import 'package:flutter/foundation.dart';

/// A path originating from the vector graphics compiler, and represented by
/// a standard [ui.Path] and a [VectorPaint] object.
@immutable
class VectorPath(this.path, this.paint) {
  /// Create from the given [path] and [paint].
  ///
  /// Throws if the [paint] has neither a fill nor a stroke.
  this {
    if (!paint.isFilled && !paint.isStroked) {
      throw ArgumentError(
        'VectorPath must have at least a stroke or a fill.',
      );
    }
  }

  /// Renders the path on the [canvas] with an optional [overridePaint], used
  /// instead of the default [paint].
  ///
  /// The fill is drawn from the original [path], so that its open contours
  /// are closed implicitly, like in the SVG file, and so is the stroke, so
  /// that closed contours are stroked as well.
  void render(ui.Canvas canvas, [VectorPaint? overridePaint]) {
    final paint = overridePaint ?? this.paint;
    if (paint.fill != null) {
      canvas.drawPath(path, paint.fill!);
    }
    if (paint.stroke != null) {
      canvas.drawPath(path, paint.stroke!);
    }
  }

  /// The default paint.
  final VectorPaint paint;

  /// The original path.
  final ui.Path path;

  @override
  String toString() => 'VectorPath(paint: $paint)';

  /// Two vector paths are equal when they have the same [path] object and the
  /// same [paint], since a [ui.Path] has no value equality.
  @override
  int get hashCode => Object.hash(paint, path);

  @override
  bool operator ==(Object other) {
    return other is VectorPath && paint == other.paint && path == other.path;
  }
}
