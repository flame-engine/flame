import 'package:flame/game.dart';
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: ExampleGame()));
}

class ExampleGame extends OxygenGame {
  @override
  Future<void> init() async {
    final entity = createEntity(
      name: 'Entity 1',
      position: Vector2.zero(),
      size: Vector2.all(64),
    )..add<SpriteComponent, SpriteInit>(
        SpriteInit(await loadSprite('pizza.png')),
      );
  }
}
