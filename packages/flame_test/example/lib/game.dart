import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGameWidget extends StatelessWidget {
  const MyGameWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: MyGame());
  }
}

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final citySprite = await loadSprite('city.png');
    await add(SpriteComponent(sprite: citySprite, size: Vector2.all(200)));
  }
}
