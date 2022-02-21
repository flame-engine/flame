import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

void main() {
  final game = MyGame();
  runApp(GameWidget(game: game));
}

class MyGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xff18679c);
}
