import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/nine_tile_box.dart';
import 'package:flame/sprite.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final size = await Flame.util.initialDimensions();

  final game = MyGame(size);
  runApp(game.widget);
}

class MyGame extends Game {
  Size size;
  NineTileBox nineTileBox;

  MyGame(this.size) {
    final sprite = Sprite('nine-box.png');
    nineTileBox = NineTileBox(sprite, tileSize: 8, destTileSize: 24);
  }

  @override
  void render(Canvas canvas) {
    const length = 300.0;
    final x = (size.width - length) / 2;
    final y = (size.height - length) / 2;
    nineTileBox.draw(canvas, x, y, length, length);
  }

  @override
  void update(double t) {}
}
