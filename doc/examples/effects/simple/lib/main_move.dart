import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/effects/effects.dart';
import 'package:flame/extensions/offset.dart';

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
      destination: details.localPosition.toVector2(),
      speed: 250.0,
      curve: Curves.bounceInOut,
    ));
  }
}

void main() {
  runApp(MyGame().widget);
}
