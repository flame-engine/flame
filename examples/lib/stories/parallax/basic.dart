import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';

class BasicParallaxGame extends BaseGame {
  final _imageNames = [
    ParallaxImageData('parallax/bg.png'),
    ParallaxImageData('parallax/mountain-far.png'),
    ParallaxImageData('parallax/mountains.png'),
    ParallaxImageData('parallax/trees.png'),
    ParallaxImageData('parallax/foreground-trees.png'),
  ];

  @override
  Future<void> onLoad() async {
    final parallax = await loadParallaxComponent(
      _imageNames,
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
    );
    add(parallax);
  }
}
