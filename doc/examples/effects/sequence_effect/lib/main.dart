import 'package:flame/effects/move_effect.dart';
import 'package:flame/effects/scale_effect.dart';
import 'package:flame/effects/rotate_effect.dart';
import 'package:flame/effects/sequence_effect.dart';
import 'package:flame/gestures.dart';
import 'package:flame/position.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import './square.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.fullScreen();
  runApp(MyGame().widget);
}

class MyGame extends BaseGame with TapDetector {
  Square greenSquare;

  MyGame() {
    final green = Paint()..color = const Color(0xAA338833);
    greenSquare = Square(green, 100, 100);
    add(greenSquare);
  }

  @override
  void onTapUp(TapUpDetails details) {
    final dx = details.localPosition.dx;
    final dy = details.localPosition.dy;
    greenSquare.clearEffects();

    final move1 = MoveEffect(
      destination: Position(dx, dy),
      speed: 250.0,
      curve: Curves.bounceInOut,
      isInfinite: false,
      isAlternating: false,
    );

    final move2 = MoveEffect(
      destination: Position(dx, dy + 150),
      speed: 150.0,
      curve: Curves.easeIn,
      isInfinite: false,
      isAlternating: true,
    );

    final scale = ScaleEffect(
      size: Size(dx, dy),
      speed: 250.0,
      curve: Curves.easeInCubic,
      isInfinite: false,
      isAlternating: false,
    );

    final rotate = RotateEffect(
      radians: (dx + dy) % pi,
      speed: 2.0,
      curve: Curves.decelerate,
      isInfinite: false,
      isAlternating: false,
    );

    final sequence = SequenceEffect(
      effects: [move1, scale, move2, rotate],
      isInfinite: true,
      isAlternating: true,
    );
    greenSquare.addEffect(sequence);
  }
}
