import 'dart:ui';

import 'package:flame/src/camera/viewport.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

/// The default viewport, which is as big as the game canvas allows.
///
/// This viewport does not perform any clipping.
class MaxViewport extends Viewport {
  MaxViewport({super.children});

  @override
  @mustCallSuper
  void onLoad() {
    size = findGame()!.canvasSize;
  }

  @override
  void onGameResize(Vector2 size) {
    this.size = size;
    super.onGameResize(size);
  }

  @override
  void clip(Canvas canvas) {}

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onViewportResize() {}
}
