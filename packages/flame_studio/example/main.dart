import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame_studio/flame_studio.dart';

void main() {
  runFlameStudio(
    GameWidget(game: MyGame()),
  );
}

class MyGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xff5c3ffb);
}
