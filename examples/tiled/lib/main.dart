import 'package:flame/components/tiled_component.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

void main() {
  var game = new TiledGame();
  runApp(game.widget);
}

class TiledGame extends BaseGame {
  TiledGame() {
    add(new TiledComponent('map.tmx'));
  }
}
