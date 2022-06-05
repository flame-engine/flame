import 'dart:ui';

import 'package:flame/src/components/component.dart';
import 'package:flame/src/experimental/viewport.dart';
import 'package:vector_math/vector_math_64.dart';

/// The default viewport, which is as big as the game canvas allows.
///
/// This viewport does not perform any clipping.
class MaxViewport extends Viewport {
  MaxViewport({Iterable<Component>? children}) : super(children: children);

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }

  @override
  void clip(Canvas canvas) {}

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onViewportResize() {}
}
