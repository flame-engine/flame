import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';

class FixedResolutionExample extends FlameGame
    with ScrollDetector, ScaleDetector {
  static const description = '''
    This example shows how to create a viewport with a fixed resolution.
    It is useful when you want the visible part of the game to be the same on
    all devices no matter the actual screen size of the device.
    Resize the window or change device orientation to see the difference.
  ''';

  FixedResolutionExample({
    required Vector2 viewportResolution,
  }) : super(
          camera: CameraComponent.withFixedResolution(
            width: viewportResolution.x,
            height: viewportResolution.y,
          ),
        );

  @override
  Future<void> onLoad() async {
    final flameSprite = await loadSprite('layers/player.png');

    world.add(Background());
    world.add(
      SpriteComponent(
        sprite: flameSprite,
        size: Vector2(149, 211),
      )..anchor = Anchor.center,
    );
  }
}

class Background extends PositionComponent with HasGameRef {
  @override
  int priority = -1;

  late Paint white;
  late final Rect hugeRect;

  Background() : super(size: Vector2.all(100000), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    white = BasicPalette.white.paint();
    hugeRect = size.toRect();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(hugeRect, white);
  }
}
