import 'package:flame/components.dart';
import 'package:flame/game.dart';

class SmallParallaxGame extends BaseGame {
  @override
  Future<void> onLoad() async {
    final component = await loadParallaxComponent(
      [
        'parallax/bg.png',
        'parallax/mountain-far.png',
        'parallax/mountains.png',
        'parallax/trees.png',
        'parallax/foreground-trees.png',
      ],
      size: Vector2.all(200),
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
    )
      ..position = size / 2;
    add(component);
  }
}
