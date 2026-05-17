import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_typled/flame_typled.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameWidget.controlled(
        gameFactory: TypledExample.new,
      ),
    );
  }
}

class TypledExample extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF2A1D3A);

  @override
  Future<void> onLoad() async {
    final atlas = await TypledSpriteAtlas.load('mini-dungeon.typled_atlas');
    final scale = Vector2.all(16);

    add(
      SpriteComponent(
        sprite: atlas.sprite('rock'),
        position: Vector2(50, 50),
        scale: scale,
      ),
    );
    add(
      SpriteComponent(
        sprite: atlas.sprite('green_globin'),
        position: Vector2(200, 220),
        scale: scale,
      ),
    );
    add(
      SpriteComponent(
        sprite: atlas.sprite('red_globin'),
        position: Vector2(10, 300),
        scale: scale,
      ),
    );
  }
}
