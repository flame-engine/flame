import 'package:flame/components/tiled_component.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

void main() {
  TiledGame game = TiledGame();
  runApp(game.widget);
}

class TiledGame extends BaseGame {
  TiledGame() {
    add(TiledComponent('map.tmx'));
  }
}
