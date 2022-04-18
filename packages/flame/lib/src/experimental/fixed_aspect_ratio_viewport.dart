import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import '../components/component.dart';
import 'viewport.dart';

class FixedAspectRatioViewport extends Viewport {
  FixedAspectRatioViewport({
    required this.aspectRatio,
    Iterable<Component>? children,
  })  : assert(aspectRatio > 0),
        super(children: children);

  final double aspectRatio;
  Rect _clipRect = Rect.zero;

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    position = canvasSize / 2;
    size = canvasSize;
  }

  @override
  void clip(Canvas canvas) => canvas.clipRect(_clipRect);

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
