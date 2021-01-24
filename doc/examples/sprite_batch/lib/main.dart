import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite_batch.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final game = MyGame();
  runApp(
    GameWidget(
      game: game,
    ),
  );
}

class MyGame extends BaseGame {
  SpriteBatch spriteBatch;

  @override
  Future<void> onLoad() async {
    spriteBatch = await SpriteBatch.load('boom3.png');

    spriteBatch.add(
      source: const Rect.fromLTWH(128 * 4.0, 128 * 4.0, 64, 128),
      offset: Vector2.all(200),
      color: Colors.greenAccent,
      scale: 2,
      rotation: pi / 9.0,
      anchor: Vector2.all(64),
    );

    spriteBatch.addTransform(
      source: const Rect.fromLTWH(128 * 4.0, 128 * 4.0, 64, 128),
      color: Colors.redAccent,
    );

    const NUM = 100;
    final r = Random();
    for (int i = 0; i < NUM; ++i) {
      final sx = r.nextInt(8) * 128.0;
      final sy = r.nextInt(8) * 128.0;
      final x = r.nextInt(size.x.toInt()).toDouble();
      final y = r.nextInt(size.y ~/ 2).toDouble() + size.y / 2.0;
      spriteBatch.add(
        source: Rect.fromLTWH(sx, sy, 128, 128),
        offset: Vector2(x - 64, y - 64),
      );
    }

    add(SpriteBatchComponent.fromSpriteBatch(
      spriteBatch,
      blendMode: BlendMode.srcOver,
    ));
  }
}
