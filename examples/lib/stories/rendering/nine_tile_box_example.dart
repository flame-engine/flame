import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class NineTileBoxExample extends FlameGame with TapDetector, DoubleTapDetector {
  static const String description = '''
    If you want to create a background for something that can stretch you can
    use the `NineTileBox` which is showcased here.\n\n
    Tap to make the box bigger and double tap to make it smaller.
  ''';

  late NineTileBox nineTileBox;
  final Vector2 boxSize = Vector2.all(300);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = Sprite(await images.load('nine-box.png'));
    nineTileBox = NineTileBox(sprite, tileSize: 8, destTileSize: 24);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final position = (size - boxSize) / 2;
    nineTileBox.draw(canvas, position, boxSize);
  }

  @override
  void onTap() {
    boxSize.scale(1.2);
  }

  @override
  void onDoubleTap() {
    boxSize.scale(0.8);
  }
}
