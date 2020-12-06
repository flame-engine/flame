import 'dart:math';

import 'package:flame/components/sprite_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Vector2 size = await Flame.util.initialDimensions();
  final game = MyGame(size);
  runApp(
    GameWidget(
      game: game,
    ),
  );
}

class MyGame extends BaseGame {
  MyGame(Vector2 screenSize) {
    size = screenSize;
  }

  @override
  Future<void> onLoad() async {
    final r = Random();
    final image = await images.load('test.png');
    List.generate(500, (i) => SpriteComponent.fromImage(Vector2.all(32), image))
        .forEach((sprite) {
      sprite.x = r.nextInt(size.x.toInt()).toDouble();
      sprite.y = r.nextInt(size.y.toInt()).toDouble();
      add(sprite);
    });
  }
}
