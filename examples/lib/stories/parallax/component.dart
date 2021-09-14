import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';

class ComponentParallaxGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(MyParallaxComponent());
  }
}

class MyParallaxComponent extends ParallaxComponent<ComponentParallaxGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    parallax = await gameRef.loadParallax(
      [
        ParallaxImageData('parallax/bg.png'),
        ParallaxImageData('parallax/mountain-far.png'),
        ParallaxImageData('parallax/mountains.png'),
        ParallaxImageData('parallax/trees.png'),
        ParallaxImageData('parallax/foreground-trees.png'),
      ],
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
    );
  }
}
