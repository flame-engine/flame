import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';

import '../components/component.dart';
import 'viewport.dart';

/// A fixed-size viewport in the shape of a circle.
class CircularViewport extends Viewport {
  CircularViewport(double radius, {Iterable<Component>? children})
      : super(children: children) {
    size = Vector2.all(2 * radius);
  }

  Path _clipPath = Path();

  @override
  void clip(Canvas canvas) => canvas.clipPath(_clipPath, doAntiAlias: false);

  @override
  void onViewportResize() {
    final x = size.x / 2;
    final y = size.y / 2;
    _clipPath = Path()..addOval(Rect.fromLTRB(-x, -y, x, y));
  }
}
