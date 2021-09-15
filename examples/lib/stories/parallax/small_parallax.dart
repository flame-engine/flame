import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';

class SmallParallaxGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final component = await loadParallaxComponent(
      [
        ParallaxImageData('parallax/bg.png'),
        ParallaxImageData('parallax/mountain-far.png'),
        ParallaxImageData('parallax/mountains.png'),
        ParallaxImageData('parallax/trees.png'),
        ParallaxImageData('parallax/foreground-trees.png'),
      ],
      size: Vector2.all(200),
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
    )
      ..position = size / 2;
    add(component);
  }
}
