import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

void main() {
  final myGame = MyGame();
  runApp(
    GameWidget(
      game: myGame,
    ),
  );
}

class MyGame extends Game {
  static const int squareSpeed = 400;
  static final squarePaint = BasicPalette.white.paint();
  late Rect squarePos;
  int squareDirection = 1;

  @override
  Future<void> onLoad() async {
    squarePos = Rect.fromLTWH(0, 0, 100, 100);
  }

  @override
  void update(double dt) {
    squarePos = squarePos.translate(squareSpeed * squareDirection * dt, 0);

    if (squareDirection == 1 && squarePos.right > size.x) {
      squareDirection = -1;
    } else if (squareDirection == -1 && squarePos.left < 0) {
      squareDirection = 1;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(squarePos, squarePaint);
  }
}
