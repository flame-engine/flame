import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame/game.dart';

class AdvancedParallaxGame extends BaseGame {
  final _layersMeta = {
    'parallax/bg.png': 1.0,
    'parallax/mountain-far.png': 1.5,
    'parallax/mountains.png': 2.3,
    'parallax/trees.png': 3.8,
    'parallax/foreground-trees.png': 6.6,
  };

  @override
  Future<void> onLoad() async {
    final layers = _layersMeta.entries.map(
      (e) => loadParallaxLayer(
        e.key,
        velocityMultiplier: Vector2(e.value, 1.0),
      ),
    );
    final parallax = ParallaxComponent.fromParallax(
      Parallax(
        await Future.wait(layers),
        size,
        baseVelocity: Vector2(20, 0),
      ),
    );
    add(parallax);
  }
}
