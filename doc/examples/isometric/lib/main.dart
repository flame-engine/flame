import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components/isometric_tile_map_component.dart';
import 'package:flame/gestures.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const x = 500.0;
const y = 500.0;
const s = 64;
final topLeft = Position(x, y);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Size size = await Flame.util.initialDimensions();
  final game = MyGame(size);
  runApp(game.widget);
}

class Selector extends SpriteComponent {
  bool show = false;

  Selector(double s)
      : super.fromSprite(s, s, Sprite('selector.png', width: 32, height: 32));

  @override
  void render(Canvas canvas) {
    if (!show) {
      return;
    }

    super.render(canvas);
  }
}

class MyGame extends BaseGame with MouseMovementDetector {
  IsometricTileMapComponent base;
  Selector selector;

  MyGame(Size size) {
    init();
  }

  void init() async {
    final tileset = await IsometricTileset.load('tiles.png', 32);
    final matrix = [
      [3, 1, 1, 1, 0, 0],
      [-1, 1, 2, 1, 0, 0],
      [-1, 0, 1, 1, 0, 0],
      [-1, 1, 1, 1, 0, 0],
      [1, 1, 1, 1, 0, 2],
      [1, 3, 3, 3, 0, 2],
    ];
    add(
      base = IsometricTileMapComponent(tileset, matrix, destTileSize: s)
        ..x = x
        ..y = y,
    );
    add(selector = Selector(s.toDouble()));
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
    final screenPosition = Position.fromOffset(event.position);
    final block = base.getBlock(screenPosition);
    selector.show = base.containsBlock(block);
    selector.setByPosition(base.getBlockPosition(block).add(topLeft));
  }
}
