import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_sprite_fusion/flame_sprite_fusion.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameWidget.controlled(
        gameFactory: () => PlatformerGame(
          camera: CameraComponent.withFixedResolution(width: 320, height: 180),
        ),
      ),
    );
  }
}

class PlatformerGame extends FlameGame {
  PlatformerGame({super.camera});

  @override
  Color backgroundColor() => Colors.white70;

  @override
  Future<void> onLoad() async {
    final map = await SpriteFusionTilemapComponent.load(
      'map.json',
      'spritesheet.png',
    );
    await world.add(map);

    camera.moveTo(map.size * 0.5);
  }
}
