import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';

import './square.dart';

class MyGame extends BaseGame with TapDetector {
  late Square square;
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
      size: Vector2(s, s),
      speed: 250.0,
      curve: Curves.bounceInOut,
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
