import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' hide Image;

const x = 500.0;
const y = 500.0;
final topLeft = Vector2(x, y);

const scale = 2.0;
const srcTileSize = 32.0;
const destTileSize = scale * srcTileSize;

final originColor = Paint()..color = const Color(0xFFFF00FF);
final originColor2 = Paint()..color = const Color(0xFFAA55FF);

const halfSize = true;
const tileHeight = scale * (halfSize ? 8.0 : 16.0);
const suffix = halfSize ? '-short' : '';

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

class IsometricTileMapGame extends FlameGame with MouseMovementDetector {
  late IsometricTileMapComponent base;
  late Selector selector;

  IsometricTileMapGame();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final tilesetImage = await images.load('tile_maps/tiles$suffix.png');
    final tileset = SpriteSheet(
      image: tilesetImage,
      srcSize: Vector2.all(srcTileSize),
    );
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
        destTileSize: Vector2.all(destTileSize),
        tileHeight: tileHeight,
      )
        ..x = x
        ..y = y,
    );

    final selectorImage = await images.load('tile_maps/selector$suffix.png');
    add(selector = Selector(destTileSize, selectorImage));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.renderPoint(topLeft, size: 5, paint: originColor);
    canvas.renderPoint(
      Vector2(x, y - tileHeight),
      size: 5,
      paint: originColor2,
    );
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    final screenPosition = info.eventPosition.game;
    final block = base.getBlock(screenPosition);
    selector.show = base.containsBlock(block);
    selector.position.setFrom(topLeft + base.getBlockPosition(block));
  }
}
