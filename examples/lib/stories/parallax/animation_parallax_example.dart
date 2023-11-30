import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';

class AnimationParallaxExample extends FlameGame {
  static const String description = '''
    Shows how to use animations in a `ParallaxComponent`.
  ''';

  @override
  Future<void> onLoad() async {
    final cityLayer = await loadParallaxLayer(
      ParallaxImageData('parallax/city.png'),
      filterQuality: FilterQuality.none,
    );

    final rainLayer = await loadParallaxLayer(
      ParallaxAnimationData(
        'parallax/rain.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.3,
          textureSize: Vector2(80, 160),
        ),
      ),
      velocityMultiplier: Vector2(2, 0),
      filterQuality: FilterQuality.none,
    );

    final cloudsLayer = await loadParallaxLayer(
      ParallaxImageData('parallax/heavy_clouded.png'),
      velocityMultiplier: Vector2(4, 0),
      fill: LayerFill.none,
      alignment: Alignment.topLeft,
      filterQuality: FilterQuality.none,
    );

    final parallax = Parallax(
      [
        cityLayer,
        rainLayer,
        cloudsLayer,
      ],
      baseVelocity: Vector2(20, 0),
    );

    final parallaxComponent = ParallaxComponent(parallax: parallax);
    add(parallaxComponent);
  }
}
