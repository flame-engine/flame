import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class SpriteBatchLoadExample extends FlameGame {
  static const String description = '''
    In this example we do the same thing as in the normal sprite batch example,
    but in this example the logic and loading is moved into a component that
    extends `SpriteBatchComponent`.
  ''';

  @override
  Future<void> onLoad() async {
    add(MySpriteBatchComponent());
  }
}

class MySpriteBatchComponent extends SpriteBatchComponent
    with HasGameReference<SpriteBatchLoadExample> {
  @override
  Future<void> onLoad() async {
    final spriteBatch = await game.loadSpriteBatch('boom.png');
    this.spriteBatch = spriteBatch;

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

    final size = game.size;
    const num = 100;
    final r = Random();
    for (var i = 0; i < num; ++i) {
      final sx = r.nextInt(8) * 128.0;
      final sy = r.nextInt(8) * 128.0;
      final x = r.nextInt(size.x.toInt()).toDouble();
      final y = r.nextInt(size.y ~/ 2).toDouble() + size.y / 2.0;
      spriteBatch.add(
        source: Rect.fromLTWH(sx, sy, 128, 128),
        offset: Vector2(x - 64, y - 64),
      );
    }
  }
}
