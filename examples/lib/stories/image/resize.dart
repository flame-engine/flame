import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

class ImageResizeExample extends FlameGame {
  ImageResizeExample(this.sizeTarget);

  static const String description = '''
     Shows how a dart:ui `Image` can be resized using Flame Image extensions.
     Use the properties on the side to change the size of the image.
  ''';

  final Vector2 sizeTarget;

  @override
  Future<void> onLoad() async {
    final image = await images.load('flame.png');

    final resized = await image.resize(sizeTarget);
    add(
      SpriteComponent(
        sprite: Sprite(resized),
        position: size / 2,
        size: resized.size,
        anchor: Anchor.center,
      ),
    );
  }
}
