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
      : super.fromSprite(
          s,
          s,
          Sprite('tiles.png', x: 64, y: 0, width: 32, height: 32),
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
  IsometricTileMapComponent base;
  Selector selector;

  MyGame(Size size) {
    init();
  }
  void init() async {
    final tileset = await IsometricTileset.load('tiles.png', 32);
    final layer0 = [
      [-1, 1, 1, 1, 0, 0],
      [-1, 1, 2, 1, 0, 0],
      [-1, 0, 1, 1, 0, 0],
      [-1, 1, 1, 1, 0, 0],
      [1, 1, 1, 1, 0, 2],
      [1, 3, 3, 3, 0, 2],
    ];
    final layer1 = [
      [-1, 0, 0, 1, -1, -1],
      [-1, 0, -1, 1, -1, -1],
      [-1, -1, 0, 1, -1, -1],
      [-1, 0, 0, 1, -1, 2],
      [0, 0, 0, 1, -1, -1],
      [0, -1, -1, -1, -1, -1],
    ];
    final layer2 = [
      [-1, -1, -1, -1, -1, -1],
      [-1, -1, -1, -1, -1, -1],
      [-1, -1, 1, -1, -1, -1],
      [-1, -1, -1, -1, -1, -1],
      [-1, -1, 1, -1, -1, -1],
      [-1, -1, -1, -1, -1, -1],
    ];
    add(
      base = IsometricTileMapComponent(tileset, layer0, destTileSize: s)
        ..x = x
        ..y = y,
    );
    // add(
    //   IsometricTileMapComponent(tileset, layer1, destTileSize: s)
    //     ..x = x
    //     ..y = y - s / 2,
    // );
    // add(
    //   IsometricTileMapComponent(tileset, layer2, destTileSize: s)
    //     ..x = x
    //     ..y = y - 2 * s / 2,
    // );
    add(selector = Selector(s.toDouble()));
  }

  @override
  void onMouseMove(PointerHoverEvent event) {
    final screenPosition = Position.fromOffset(event.position);
    final blockCoords = base.getBlock(screenPosition);
    final blockPosition =
        base.cartToIso(Position.fromInts(blockCoords.x * s, blockCoords.y * s));
    selector.setByPosition(blockPosition.add(topLeft));
    selector.show = true;
  }
}
