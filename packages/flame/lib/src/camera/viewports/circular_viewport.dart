import 'dart:ui';

import 'package:flame/src/camera/viewport.dart';
import 'package:vector_math/vector_math_64.dart';

/// A fixed-size viewport in the shape of a circle (or ellipse).
class CircularViewport extends Viewport {
  CircularViewport(double radius, {super.children}) {
    _radiusX = radius;
    _radiusY = radius;
    size = Vector2.all(2 * radius);
  }

  Path _clipPath = Path();
  double _radiusX = 0;
  double _radiusY = 0;

  @override
  void clip(Canvas canvas) => canvas.clipPath(_clipPath, doAntiAlias: false);

  @override
  bool containsLocalPoint(Vector2 point) {
    final fx = point.x / _radiusX - 1;
    final fy = point.y / _radiusY - 1;
    return fx * fx + fy * fy <= 1;
  }

  @override
  void onViewportResize() {
    _radiusX = size.x / 2;
    _radiusY = size.y / 2;
    _clipPath = Path()..addOval(Rect.fromLTRB(0, 0, size.x, size.y));
  }
}
