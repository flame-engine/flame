import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';

class FixedResolutionGame extends FlameGame with ScrollDetector, ScaleDetector {
  static const info = '''
  This example shows how to create a viewport with a fixed resolution.
  It is useful when you want the visible part of the game to be the same on all
  devices no matter the actual screen size of the device.
  Resize the window or change device orientation to see the difference.
  ''';

  final Vector2 viewportResolution;

  FixedResolutionGame({
    required this.viewportResolution,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final flameSprite = await loadSprite('layers/player.png');

    camera.viewport = FixedResolutionViewport(viewportResolution);
    camera.setRelativeOffset(Anchor.topLeft);
    camera.speed = 1;

    add(Background());
    add(
      SpriteComponent(
        position: camera.viewport.effectiveSize / 2,
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

  Background() : super(size: Vector2.all(100000));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    white = BasicPalette.white.paint();
    hugeRect = size.toRect();
  }

  @override
  void render(Canvas c) {
    super.render(c);
    c.drawRect(hugeRect, white);
  }
}
