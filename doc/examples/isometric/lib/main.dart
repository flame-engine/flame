import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Image;

import 'dart:ui';

const x = 500.0;
const y = 500.0;
const s = 64.0;
final topLeft = Vector2(x, y);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

class Selector extends SpriteComponent {
  bool show = false;

  Selector(double s, Image image)
      : super.fromSprite(
          Vector2.all(s),
          Sprite(image, srcSize: Vector2.all(32.0)),
        );

  @override
  void render(Canvas canvas) {
    if (!show) {
      return;
    }

    super.render(canvas);
  }
}

class MyGame extends BaseGame with MouseMovementDetector {
  IsometricTileMapComponent? base;
  Selector? selector;

  MyGame();

  @override
  Future<void> onLoad() async {
    final selectorImage = await images.load('selector.png');

    final tilesetImage = await images.load('tiles.png');
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

    canvas.drawRect(
      const Rect.fromLTWH(x - 1, y - 1, 3, 3),
      Paint()..color = const Color(0xFFFF00FF),
    );
  }

  @override
  void onMouseMove(PointerHoverEvent event) {
    if (base == null || selector == null) {
      return; // loading
    }
    final offset = event.position;
    final screenPosition = Vector2(offset.dx, offset.dy);
    final block = base!.getBlock(screenPosition);
    selector!.show = base!.containsBlock(block);
    selector!.position = base!.getBlockPosition(block) + topLeft;
  }
}
