import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components/isometric_tile_map_component.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Size size = await Flame.util.initialDimensions();
  final game = MyGame(size);
  runApp(game.widget);
}

class MyGame extends BaseGame {
  MyGame(Size size) {
    init();
  }
  void init() async {
    final tileset = await IsometricTileset.load('tiles.png', 32);
    final matrix = [
      [-1, 1, 1, 1, 0, 0],
      [-1, 1, 2, 1, 0, 0],
      [-1, 0, 1, 1, 0, 0],
      [-1, 1, 1, 1, 0, 0],
      [1, 1, 1, 1, 0, 2],
      [1, 3, 3, 3, 0, 2],
    ];
    add(
      IsometricTileMapComponent(tileset, matrix)
        ..x = 100
        ..y = 100,
    );
  }
}
