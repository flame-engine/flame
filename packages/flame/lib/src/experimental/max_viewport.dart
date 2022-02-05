import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import 'viewport.dart';

class MaxViewport extends Viewport {
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
    position = gameSize / 2;
  }

  @override
  void clip(Canvas canvas) {}

  @override
  void handleResize() {}
}
