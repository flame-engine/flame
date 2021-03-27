import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Image;

const x = 500.0;
const y = 500.0;
const s = 64.0;
final topLeft = Vector2(x, y);
final originColor = Paint()..color = const Color(0xFFFF00FF);

class Selector extends SpriteComponent {
  bool show = false;

  Selector(double s, Image image)
      : super(
          sprite: Sprite(image, srcSize: Vector2.all(32.0)),
          size: Vector2.all(s),
        );

  @override
  void render(Canvas canvas) {
    if (!show) {
      return;
    }

    super.render(canvas);
  }
}

class IsometricTileMapGame extends BaseGame with MouseMovementDetector {
  late IsometricTileMapComponent base;
  late Selector selector;

  IsometricTileMapGame();

  @override
  Future<void> onLoad() async {
    final selectorImage = await images.load('tile_maps/selector.png');

    final tilesetImage = await images.load('tile_maps/tiles.png');
    final tileset = SpriteSheet(image: tilesetImage, srcSize: Vector2.all(32));
    final matrix = [
      [3, 1, 1, 1, 0, 0],
      [-1, 1, 2, 1, 0, 0],
      [-1, 0, 1, 1, 0, 0],
      [-1, 1, 1, 1, 0, 0],
      [1, 1, 1, 1, 0, 2],
      [1, 3, 3, 3, 0, 2],
    ];
    add(
      base = IsometricTileMapComponent(
        tileset,
        matrix,
        destTileSize: Vector2.all(s),
      )
        ..x = x
        ..y = y,
    );
    add(selector = Selector(s, selectorImage));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(const Rect.fromLTWH(x - 1, y - 1, 3, 3), originColor);
  }

  @override
  void onMouseMove(PointerHoverEvent event) {
    final screenPosition = event.localPosition.toVector2();
    final block = base.getBlock(screenPosition);
    selector.show = base.containsBlock(block);
    selector.position = base.getBlockPosition(block) + topLeft;
  }
}
