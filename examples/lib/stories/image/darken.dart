import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

class ImageDarknessExample extends FlameGame {
  ImageDarknessExample({
    required this.darkness,
  });

  final double darkness;

  static const String description = '''
     Shows how a dart:ui `Image` can be darkened using Flame Image extensions.
     Use the properties on the side to change the darkeness of the image.
  ''';

  @override
  Future<void> onLoad() async {
    final image = await images.load('flame.png');
    final darkendImage = await image.darken(darkness / 100);

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
        sprite: Sprite(darkendImage),
        position: (size / 2) + Vector2(0, darkendImage.height / 2),
        size: image.size,
        anchor: Anchor.center,
      ),
    );
  }
}
