import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GameWidget(game: MyGame());
  }
}

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final citySprite = await loadSprite('city.png');
    await add(SpriteComponent(sprite: citySprite, size: Vector2.all(200)));
  }
}
