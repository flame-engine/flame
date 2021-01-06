import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/gestures.dart';

import './square.dart';

class MyGame extends BaseGame with TapDetector {
  late Square square;

  MyGame() {
    add(square = Square()
      ..anchor = Anchor.center
      ..x = 200
      ..y = 200);
  }

  @override
  void onTap() {
    square.addEffect(RotateEffect(
      angle: 2 * pi,
      isRelative: true,
      duration: 5.0,
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
