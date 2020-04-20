import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite_batch.dart';
import 'package:flame/components/sprite_batch_component.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Size size = await Flame.util.initialDimensions();
  final game = MyGame(size);
  runApp(game.widget);
}

class MyGame extends BaseGame {
  SpriteBatch spriteBatch;

  MyGame(Size screenSize) {
    size = screenSize;

    initData();
  }

  void initData() async {
    spriteBatch = await SpriteBatch.withAsset('boom3.png');

    spriteBatch.add(
      rect: const Rect.fromLTWH(128 * 4.0, 128 * 4.0, 64, 128),
      offset: const Offset(200, 200),
      color: Colors.greenAccent,
      scale: 2,
      rotation: pi / 9.0,
      anchor: const Offset(64, 64),
    );

    spriteBatch.addTransform(
      rect: const Rect.fromLTWH(128 * 4.0, 128 * 4.0, 64, 128),
      color: Colors.redAccent,
    );

    const NUM = 100;
    final r = Random();
    for (int i = 0; i < NUM; ++i) {
      final sx = r.nextInt(8) * 128.0;
      final sy = r.nextInt(8) * 128.0;
      final x = r.nextInt(size.width.toInt()).toDouble();
      final y = r.nextInt(size.height ~/ 2).toDouble() + size.height / 2.0;
      spriteBatch.add(
        rect: Rect.fromLTWH(sx, sy, 128, 128),
        offset: Offset(x - 64, y - 64),
      );
    }

    add(SpriteBatchComponent.fromSpriteBatch(
      spriteBatch,
      blendMode: BlendMode.srcOver,
    ));
  }
}
