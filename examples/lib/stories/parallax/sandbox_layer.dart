import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';

class SandBoxLayerParallaxGame extends FlameGame {
  final Vector2 planeSpeed;
  final ImageRepeat planeRepeat;
  final LayerFill planeFill;
  final Alignment planeAlignment;

  SandBoxLayerParallaxGame({
    required this.planeSpeed,
    required this.planeRepeat,
    required this.planeFill,
    required this.planeAlignment,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final bgLayer = await loadParallaxLayer(
      ParallaxImageData('parallax/bg.png'),
    );
    final mountainFarLayer = await loadParallaxLayer(
      ParallaxImageData('parallax/mountain-far.png'),
      velocityMultiplier: Vector2(1.8, 0),
    );
    final mountainLayer = await loadParallaxLayer(
      ParallaxImageData('parallax/mountains.png'),
      velocityMultiplier: Vector2(2.8, 0),
    );
    final treeLayer = await loadParallaxLayer(
      ParallaxImageData('parallax/trees.png'),
      velocityMultiplier: Vector2(3.8, 0),
    );
    final foregroundTreesLayer = await loadParallaxLayer(
      ParallaxImageData('parallax/foreground-trees.png'),
      velocityMultiplier: Vector2(4.8, 0),
    );
    final airplaneLayer = await loadParallaxLayer(
      ParallaxAnimationData(
        'parallax/airplane.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.2,
          textureSize: Vector2(320, 160),
        ),
      ),
      repeat: planeRepeat,
      velocityMultiplier: planeSpeed,
      fill: planeFill,
      alignment: planeAlignment,
    );

    final parallax = Parallax(
      [
        bgLayer,
        mountainFarLayer,
        mountainLayer,
        treeLayer,
        foregroundTreesLayer,
        airplaneLayer,
      ],
      baseVelocity: Vector2(20, 0),
    );

    add(ParallaxComponent.fromParallax(parallax));
  }
}
