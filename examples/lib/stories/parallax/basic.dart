import 'package:flame/components.dart';
import 'package:flame/game.dart';

class BasicParallaxGame extends BaseGame {
  final _imageNames = [
    'parallax/bg.png',
    'parallax/mountain-far.png',
    'parallax/mountains.png',
    'parallax/trees.png',
    'parallax/foreground-trees.png',
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
