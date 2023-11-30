import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';

class SandboxLayerParallaxExample extends FlameGame {
  static const String description = '''
    In this example, properties of a layer can be changed to preview the
    different combination of values. You can change the properties by pressing
    the pen in the upper right corner.
  ''';

  final Vector2 planeSpeed;
  final ImageRepeat planeRepeat;
  final LayerFill planeFill;
  final Alignment planeAlignment;

  SandboxLayerParallaxExample({
    required this.planeSpeed,
    required this.planeRepeat,
    required this.planeFill,
    required this.planeAlignment,
  });

  @override
  Future<void> onLoad() async {
    final bgLayer = await loadParallaxLayer(
      ParallaxImageData('parallax/bg.png'),
      filterQuality: FilterQuality.none,
    );
    final mountainFarLayer = await loadParallaxLayer(
      ParallaxImageData('parallax/mountain-far.png'),
      velocityMultiplier: Vector2(1.8, 0),
      filterQuality: FilterQuality.none,
    );
    final mountainLayer = await loadParallaxLayer(
      ParallaxImageData('parallax/mountains.png'),
      velocityMultiplier: Vector2(2.8, 0),
      filterQuality: FilterQuality.none,
    );
    final treeLayer = await loadParallaxLayer(
      ParallaxImageData('parallax/trees.png'),
      velocityMultiplier: Vector2(3.8, 0),
      filterQuality: FilterQuality.none,
    );
    final foregroundTreesLayer = await loadParallaxLayer(
      ParallaxImageData('parallax/foreground-trees.png'),
      velocityMultiplier: Vector2(4.8, 0),
      filterQuality: FilterQuality.none,
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
      filterQuality: FilterQuality.none,
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

    add(ParallaxComponent(parallax: parallax));
  }
}
