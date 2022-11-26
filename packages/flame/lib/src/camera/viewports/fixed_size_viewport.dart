import 'dart:ui';

import 'package:flame/src/camera/viewport.dart';
import 'package:vector_math/vector_math_64.dart';

/// A rectangular viewport with fixed dimensions.
///
/// You can change the size of this viewport at runtime, but it will not
/// auto-resize when its parent changes size.
class FixedSizeViewport extends Viewport {
  FixedSizeViewport(
    double width,
    double height, {
    super.children,
  }) {
    size = Vector2(width, height);
  }

  late Rect _clipRect;

  @override
  void clip(Canvas canvas) => canvas.clipRect(_clipRect, doAntiAlias: false);

  @override
  bool containsLocalPoint(Vector2 point) {
    final x = point.x, y = point.y;
    return x >= 0 && x <= size.x && y >= 0 && y <= size.y;
  }

  @override
  void onViewportResize() {
    _clipRect = Rect.fromLTWH(0, 0, size.x, size.y);
  }
}
