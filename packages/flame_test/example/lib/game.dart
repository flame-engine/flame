import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGameWidget extends StatelessWidget {
  const MyGameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: MyGame());
  }
}

class Background extends SpriteComponent with HasGameReference<MyGame> {
  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('city.png');
    size = Vector2.all(200);
    position = Vector2.all(100);
  }
}

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await world.add(Background());
  }
}
