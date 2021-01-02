import 'package:flame/effects/move_effect.dart';
import 'package:flame/effects/scale_effect.dart';
import 'package:flame/effects/rotate_effect.dart';
import 'package:flame/gestures.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import './square.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.fullScreen();
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

const green = Color(0xAA338833);
const red = Color(0xAA883333);
const orange = Color(0xAABB6633);

class MyGame extends BaseGame with TapDetector {
  Square greenSquare;
  Square redSquare;
  Square orangeSquare;

  MyGame()
      : greenSquare = Square(Paint()..color = green, Vector2.all(100)),
        redSquare = Square(Paint()..color = red, Vector2.all(200)),
        orangeSquare = Square(Paint()..color = orange, Vector2(200, 400)) {
    add(greenSquare);
    add(redSquare);
    add(orangeSquare);
  }

  @override
  void onTapUp(TapUpDetails details) {
    final dx = details.localPosition.dx;
    final dy = details.localPosition.dy;

    greenSquare.clearEffects();
    redSquare.clearEffects();
    orangeSquare.clearEffects();

    greenSquare.addEffect(MoveEffect(
      path: [Vector2(dx, dy)],
      speed: 250.0,
      curve: Curves.bounceInOut,
      isInfinite: true,
      isAlternating: true,
    ));

    redSquare.addEffect(ScaleEffect(
      size: Vector2(dx, dy),
      speed: 250.0,
      curve: Curves.easeInCubic,
      isInfinite: true,
      isAlternating: true,
    ));

    orangeSquare.addEffect(RotateEffect(
      angle: (dx + dy) % (2 * pi),
      speed: 1.0, // Radians per second
      curve: Curves.easeInOut,
      isInfinite: true,
      isAlternating: true,
    ));
  }
}
