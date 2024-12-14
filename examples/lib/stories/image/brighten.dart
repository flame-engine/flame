import 'dart:io';
import 'dart:ui' as ui;

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
    final brightenedImage = await image.brighten(brightness / 100);
    await saveImage(brightenedImage, '/tmp/brightened.png');

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
        sprite: Sprite(brightenedImage),
        position: (size / 2) + Vector2(0, brightenedImage.height / 2),
        size: image.size,
        anchor: Anchor.center,
      ),
    );
  }
}

Future<void> saveImage(ui.Image image, String filename) async {
  final byteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  final pngBytes = byteData!.buffer.asUint8List();
  await File(filename).writeAsBytes(pngBytes);
}
