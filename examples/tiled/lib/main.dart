import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flame/tiled/tiled_component.dart';

void main() {
  var game = new TiledGame();
  runApp(game.widget);
}

class TiledGame extends BaseGame {
  TiledGame() {
    add(new TiledComponent('map.tmx'));
  }
}
