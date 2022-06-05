import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import 'package:klondike/step2/klondike_game.dart';

void main() {
  final game = KlondikeGame();
  runApp(GameWidget(game: game));
}
