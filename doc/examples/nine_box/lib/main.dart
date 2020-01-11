import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/nine_box.dart';
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
  NineBox nineBox;

  MyGame(this.size) {
    final sprite = Sprite('nine-box.png');
    nineBox = NineBox(sprite, tileSize: 8, destTileSize: 24);
  }

  @override
  void render(Canvas canvas) {
    final length = 300.0;
    nineBox.draw(canvas, (size.width - length) / 2, (size.height - length) / 2,
        length, length);
  }

  @override
  void update(double t) {}
}
