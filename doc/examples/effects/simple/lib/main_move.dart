import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

import './square.dart';

class MyGame extends BaseGame with TapDetector {
  late Square square;

  MyGame() {
    add(square = Square()
      ..x = 100
      ..y = 100);
  }

  @override
  void onTapUp(TapUpDetails details) {
    square.addEffect(MoveEffect(
      path: [
        details.localPosition.toVector2(),
        Vector2(100, 100),
        Vector2(50, 120),
        Vector2(200, 400),
        Vector2(150, 0),
        Vector2(100, 300),
      ],
      speed: 250.0,
      curve: Curves.bounceInOut,
      isRelative: false,
      isInfinite: false,
      isAlternating: true,
    ));
  }
}

void main() {
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}
