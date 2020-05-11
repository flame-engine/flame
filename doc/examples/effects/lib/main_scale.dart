import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/anchor.dart';
import 'package:flame/effects/effects.dart';

import './square.dart';

class MyGame extends BaseGame with TapDetector {
  Square square;
  bool grow = true;

  MyGame() {
    add(square = Square()
      ..anchor = Anchor.center
      ..x = 200
      ..y = 200);
  }

  @override
  void onTap() {
    final s = grow ? 300.0 : 100.0;

    grow = !grow;
    square.addEffect(ScaleEffect(
      size: Size(s, s),
      speed: 250.0,
      curve: Curves.bounceInOut,
    ));
  }
}

void main() {
  runApp(MyGame().widget);
}
