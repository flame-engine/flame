import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';

import 'viewport.dart';

/// A fixed-size viewport in the shape of a circle.
class CircularViewport extends Viewport {
  CircularViewport(double radius) {
    size = Vector2.all(2 * radius);
  }

  Path _clipPath = Path();
  double _radiusSquared = 0;

  @override
  void clip(Canvas canvas) => canvas.clipPath(_clipPath, doAntiAlias: false);

  @override
  bool containsPoint(Vector2 point) => point.length2 <= _radiusSquared;

  @override
  void onViewportResize() {
    assert(size.x == size.y, 'Viewport shape is not circular: $size');
    final x = size.x / 2;
    _clipPath = Path()..addOval(Rect.fromLTRB(-x, -x, x, x));
    _radiusSquared = x * x;
  }
}
