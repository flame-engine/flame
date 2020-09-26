import 'dart:math';

import 'package:flame/components/sprite_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Size size = await Flame.util.initialDimensions();
  final game = MyGame(size);
  runApp(game.widget);
}

class MyGame extends BaseGame {
  MyGame(Size screenSize) {
    size = screenSize;
  }

  @override
  Future<void> onLoad() async {
    final r = Random();
    final image = await images.load('test.png');
    List.generate(500, (i) => SpriteComponent.square(32, image))
        .forEach((sprite) {
      sprite.x = r.nextInt(size.width.toInt()).toDouble();
      sprite.y = r.nextInt(size.height.toInt()).toDouble();
      add(sprite);
    });
  }
}
