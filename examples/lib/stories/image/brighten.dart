import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

class ImageBrightnessExample extends FlameGame {
  ImageBrightnessExample({
    required this.brightness,
  });

  final double brightness;

  static const String description = '''
     Shows how a dart:ui `Image` can be brightened using Flame Image extensions.
     Use the properties on the side to change the brightness of the image.
  ''';

  @override
  Future<void> onLoad() async {
    final image = await images.load('flame.png');
    final brightenImageimage = await image.brighten(brightness / 100);

    add(
      SpriteComponent(
        sprite: Sprite(image),
        position: (size / 2) - Vector2(0, image.height / 2),
        size: image.size,
        anchor: Anchor.center,
      ),
    );

    add(
      SpriteComponent(
        sprite: Sprite(brightenImageimage),
        position: (size / 2) + Vector2(0, brightenImageimage.height / 2),
        size: image.size,
        anchor: Anchor.center,
      ),
    );
  }
}
