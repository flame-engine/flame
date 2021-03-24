import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';

class ComponentParallaxGame extends BaseGame {
  @override
  Future<void> onLoad() async {
    add(MyParallaxComponent());
  }
}

class MyParallaxComponent extends ParallaxComponent
    with HasGameRef<ComponentParallaxGame> {
  @override
  Future<void> onLoad() async {
    parallax = await gameRef!.loadParallax(
      [
        'parallax/bg.png',
        'parallax/mountain-far.png',
        'parallax/mountains.png',
        'parallax/trees.png',
        'parallax/foreground-trees.png',
      ],
      size,
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
    );
  }
}
