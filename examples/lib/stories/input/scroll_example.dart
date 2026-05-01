import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class ScrollExample extends FlameGame with ScrollCallbacks {
  static const String description = '''
    In this example we show how to use `ScrollCallbacks`.\n\n
    Scroll over the colored squares to scale them. Scroll anywhere else on the
    canvas to pan the camera. Both behaviors use the same `ScrollCallbacks`
    mixin — on the game for camera movement, and on each square component for
    scaling.
  ''';

  @override
  Future<void> onLoad() async {
    world.add(
      ScrollableSquare(
        paint: BasicPalette.blue.paint(),
        position: Vector2(-100, 0),
      ),
    );
    world.add(
      ScrollableSquare(
        paint: BasicPalette.green.paint(),
        position: Vector2(100, 0),
      ),
    );
  }

  @override
  void onScroll(ScrollEvent event) {
    camera.moveBy(event.scrollDelta * 3);
  }
}

class ScrollableSquare extends RectangleComponent with ScrollCallbacks {
  ScrollableSquare({required Paint paint, required Vector2 position})
    : super(
        position: position,
        size: Vector2.all(100),
        paint: paint,
        anchor: Anchor.center,
      );

  @override
  void onScroll(ScrollEvent event) {
    // Scroll up to grow, scroll down to shrink
    final factor = switch (event.scrollDelta.y.sign) {
      1 => 0.9,
      -1 => 1.1,
      _ => 1.0,
    };
    scale.scale(factor);
    scale.clampScalar(0.3, 5.0);

    // Stop propagation so the game-level handler doesn't pick it up
    event.continuePropagation = false;
  }
}
