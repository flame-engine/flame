import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';

class ComponentParallaxExample extends FlameGame {
  static const String description = '''
    Shows how to do initiation and loading of assets from within an extended
    `ParallaxComponent`. This example uses a `FixedResolutionViewport` which
    the `ParallaxComponent` is fullscreen within.
  ''';

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(800, 600),
    );
    camera.viewport.add(MyParallaxComponent());
  }
}

class MyParallaxComponent extends ParallaxComponent<ComponentParallaxExample> {
  @override
  Future<void> onLoad() async {
    parallax = await game.loadParallax(
      [
        ParallaxImageData('parallax/bg.png'),
        ParallaxImageData('parallax/mountain-far.png'),
        ParallaxImageData('parallax/mountains.png'),
        ParallaxImageData('parallax/trees.png'),
        ParallaxImageData('parallax/foreground-trees.png'),
      ],
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
      filterQuality: FilterQuality.none,
    );
  }
}
