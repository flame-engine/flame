import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';

class StaticComponentsExample extends FlameGame
    with ScrollDetector, ScaleDetector {
  static const description = '''
  This example shows a parallax which is attached to the viewport (behind the
  world), four Flame logos that are added to the world, and a player added to
  the world which is also followed by the camera when you click somewhere.
  The text components that are added are self-explanatory.
  ''';

  late final ParallaxComponent myParallax;

  StaticComponentsExample({
    required Vector2 viewportResolution,
  }) : super(
          camera: CameraComponent.withFixedResolution(
            width: viewportResolution.x,
            height: viewportResolution.y,
          ),
          world: _StaticComponentWorld(),
        );

  @override
  Future<void> onLoad() async {
    myParallax = MyParallaxComponent()..parallax?.baseVelocity.setZero();
    camera.backdrop.addAll([
      myParallax,
      TextComponent(
        text: 'Center backdrop Component',
        position: camera.viewport.virtualSize / 2 + Vector2(0, 30),
        anchor: Anchor.center,
      ),
    ]);
    camera.viewport.addAll(
      [
        TextComponent(
          text: 'Corner Viewport Component',
          position: Vector2.all(10),
        ),
        TextComponent(
          text: 'Center Viewport Component',
          position: camera.viewport.virtualSize / 2,
          anchor: Anchor.center,
        ),
      ],
    );
  }
}

class _StaticComponentWorld extends World
    with
        HasGameReference<StaticComponentsExample>,
        TapCallbacks,
        DoubleTapCallbacks {
  late SpriteComponent player;
  @override
  Future<void> onLoad() async {
    final playerSprite = await game.loadSprite('layers/player.png');
    final flameSprite = await game.loadSprite('flame.png');
    final visibleSize = game.camera.visibleWorldRect.toVector2();
    add(player = SpriteComponent(sprite: playerSprite, anchor: Anchor.center));
    addAll([
      SpriteComponent(
        sprite: flameSprite,
        anchor: Anchor.center,
        position: -visibleSize / 8,
        size: Vector2(20, 30),
      ),
      SpriteComponent(
        sprite: flameSprite,
        anchor: Anchor.center,
        position: visibleSize / 8,
        size: Vector2(20, 30),
      ),
      SpriteComponent(
        sprite: flameSprite,
        anchor: Anchor.center,
        position: (visibleSize / 8)..multiply(Vector2(-1, 1)),
        size: Vector2(20, 30),
      ),
      SpriteComponent(
        sprite: flameSprite,
        anchor: Anchor.center,
        position: (visibleSize / 8)..multiply(Vector2(1, -1)),
        size: Vector2(20, 30),
      ),
    ]);
    game.camera.follow(player, maxSpeed: 100);
  }

  @override
  void onTapDown(TapDownEvent event) {
    const moveDuration = 1.0;
    final deltaX = (event.localPosition - player.position).x;
    player.add(
      MoveToEffect(
        event.localPosition,
        EffectController(
          duration: moveDuration,
        ),
        onComplete: () => game.myParallax.parallax?.baseVelocity.setZero(),
      ),
    );
    final moveSpeedX = deltaX / moveDuration;
    game.myParallax.parallax?.baseVelocity.setValues(moveSpeedX, 0);
  }
}

class MyParallaxComponent extends ParallaxComponent {
  @override
  Future<void> onLoad() async {
    parallax = await game.loadParallax(
      [
        ParallaxImageData('parallax/bg.png'),
        ParallaxImageData('parallax/mountain-far.png'),
        ParallaxImageData('parallax/mountains.png'),
        ParallaxImageData('parallax/trees.png'),
        ParallaxImageData('parallax/foreground-trees.png'),
      ],
      baseVelocity: Vector2(0, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
      filterQuality: FilterQuality.none,
    );
  }
}
