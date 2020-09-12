import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/effects/effects.dart';
import 'package:flame/vector2.dart';

import './square.dart';

class MyGame extends BaseGame with TapDetector {
  Square square;
  MyGame() {
    add(square = Square()
      ..x = 100
      ..y = 100);
  }

  @override
  void onTapUp(details) {
    square.addEffect(MoveEffect(
      destination: Vector2Operations.fromOffset(details.localPosition),
      speed: 250.0,
      curve: Curves.bounceInOut,
    ));
  }
}

void main() {
  runApp(MyGame().widget);
}
