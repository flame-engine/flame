import 'dart:ui';

import 'package:flame/src/experimental/viewport.dart';
import 'package:vector_math/vector_math_64.dart';

class FixedAspectRatioViewport extends Viewport {
  FixedAspectRatioViewport({
    required this.aspectRatio,
    super.children,
  }) : assert(aspectRatio > 0);

  final double aspectRatio;
  Rect _clipRect = Rect.zero;

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    position = canvasSize / 2;
    size = canvasSize;
  }

  @override
  void clip(Canvas canvas) => canvas.clipRect(_clipRect, doAntiAlias: false);

  @override
  bool containsLocalPoint(Vector2 point) {
    return point.x.abs() <= size.x / 2 && point.y.abs() <= size.y / 2;
  }

  @override
  void onViewportResize() {
    final desiredWidth = size.y * aspectRatio;
    if (desiredWidth > size.x) {
      size.y = size.x / aspectRatio;
    } else {
      size.x = desiredWidth;
    }

    final x = size.x / 2;
    final y = size.y / 2;
    _clipRect = Rect.fromLTRB(-x, -y, x, y);
  }
}
