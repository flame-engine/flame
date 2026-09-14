import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';

class SmallParallaxExample extends FlameGame {
  static const String description = '''
    Shows how to create a smaller parallax in the center of the screen.
  ''';

  @override
  Future<void> onLoad() async {
    final component = await loadParallaxComponent(
      [
        ParallaxImageData('assets/images/parallax/bg.png'),
        ParallaxImageData('assets/images/parallax/mountain-far.png'),
        ParallaxImageData('assets/images/parallax/mountains.png'),
        ParallaxImageData('assets/images/parallax/trees.png'),
        ParallaxImageData('assets/images/parallax/foreground-trees.png'),
      ],
      size: Vector2.all(200),
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
    );
    component.position = size / 2;
    add(component);
  }
}
