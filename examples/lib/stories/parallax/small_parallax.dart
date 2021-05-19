import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';

class SmallParallaxGame extends BaseGame {
  @override
  Future<void> onLoad() async {
    final parallaxSize = Vector2.all(200);
    final parallax = await loadParallax(
      [
        'parallax/bg.png',
        'parallax/mountain-far.png',
        'parallax/mountains.png',
        'parallax/trees.png',
        'parallax/foreground-trees.png',
      ],
      size: parallaxSize,
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
    );
    final component = ParallaxComponent.fromParallax(
      parallax,
      position: size / 2,
    )..anchor = Anchor.center;
    add(component);
  }
}
