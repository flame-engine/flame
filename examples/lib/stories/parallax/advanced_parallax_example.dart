import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';

class AdvancedParallaxExample extends FlameGame {
  static const String description = '''
    Shows how to create a parallax with different velocity deltas on each layer.
  ''';

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
        ParallaxImageData(e.key),
        velocityMultiplier: Vector2(e.value, 1.0),
        filterQuality: FilterQuality.none,
      ),
    );
    final parallax = ParallaxComponent(
      parallax: Parallax(
        await Future.wait(layers),
        baseVelocity: Vector2(20, 0),
      ),
    );
    add(parallax);
  }
}
