import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import '../components/component.dart';
import 'viewport.dart';

/// The default viewport, which is as big as the game canvas allows.
///
/// This viewport does not perform any clipping.
class MaxViewport extends Viewport {
  MaxViewport({Iterable<Component>? children}) : super(children: children);

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
    position = gameSize / 2;
  }

  @override
  void clip(Canvas canvas) {}

  @override
  void onViewportResize() {}
}
