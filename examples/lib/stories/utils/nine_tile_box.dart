import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class NineTileBoxGame extends FlameGame {
  late NineTileBox nineTileBox;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = Sprite(await images.load('nine-box.png'));
    nineTileBox = NineTileBox(sprite, tileSize: 8, destTileSize: 24);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    const length = 300.0;
    final boxSize = Vector2.all(length);
    final position = (size - boxSize) / 2;
    nineTileBox.draw(canvas, position, boxSize);
  }
}
