import 'dart:math';

import 'package:flame/components/component.dart';
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
  void onAttach() {
    super.onAttach();

    initSprites();
  }

  void initSprites() async {
    final r = Random();
    List.generate(500, (i) => SpriteComponent.square(32, 'test.png'))
        .forEach((sprite) {
      sprite.x = r.nextInt(size.width.toInt()).toDouble();
      sprite.y = r.nextInt(size.height.toInt()).toDouble();
      add(sprite);
    });
  }
}
