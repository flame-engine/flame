import 'package:flame/effects/move_effect.dart';
import 'package:flame/effects/scale_effect.dart';
import 'package:flame/gestures.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:infinite_effects/square.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.fullScreen();
  runApp(MyGame().widget);
}

class MyGame extends BaseGame with TapDetector {
  Square greenSquare;
  Square redSquare;

  MyGame() {
    final green = Paint()..color = const Color(0xAA338833);
    final red = Paint()..color = const Color(0xAA883333);
    greenSquare = Square(green, 100, 100);
    redSquare = Square(red, 200, 200);
    add(greenSquare);
    add(redSquare);
  }

  @override
  void onTapUp(details) {
    greenSquare.clearEffects();
    final dx = details.localPosition.dx;
    final dy = details.localPosition.dy;
    greenSquare.addEffect(MoveEffect(
      destination: Position(dx, dy),
      speed: 250.0,
      curve: Curves.bounceInOut,
      isInfinite: true,
      isAlternating: true
    ));
    redSquare.clearEffects();
    redSquare.addEffect(ScaleEffect(
        size: Size(dx, dy),
        speed: 250.0,
        curve: Curves.easeInCubic,
        isInfinite: true,
        isAlternating: true
    ));
  }
}

