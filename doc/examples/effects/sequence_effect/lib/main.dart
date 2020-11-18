import 'package:flame/effects/combined_effect.dart';
import 'package:flame/effects/move_effect.dart';
import 'package:flame/effects/scale_effect.dart';
import 'package:flame/effects/rotate_effect.dart';
import 'package:flame/effects/sequence_effect.dart';
import 'package:flame/gestures.dart';
import 'package:flame/extensions/offset.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

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
    greenSquare = Square(green, Vector2.all(100));
    add(greenSquare);
  }

  @override
  void onTapUp(TapUpDetails details) {
    final Vector2 currentTap = details.localPosition.toVector2();
    greenSquare.clearEffects();

    final move1 = MoveEffect(
      path: [currentTap],
      speed: 250.0,
      curve: Curves.bounceInOut,
      isInfinite: false,
      isAlternating: true,
    );

    final move2 = MoveEffect(
      path: [
        currentTap + Vector2(0, 50),
        currentTap + Vector2(-50, -50),
        currentTap + Vector2(50, 0),
      ],
      speed: 150.0,
      curve: Curves.easeIn,
      isInfinite: false,
      isAlternating: false,
    );

    final scale = ScaleEffect(
      size: currentTap,
      speed: 100.0,
      curve: Curves.easeInCubic,
      isInfinite: false,
      isAlternating: false,
    );

    final rotate = RotateEffect(
      angle: currentTap.angleTo(Vector2.all(100)),
      duration: 0.8,
      curve: Curves.decelerate,
      isInfinite: false,
      isAlternating: false,
    );

    final combination = CombinedEffect(
      effects: [move2, rotate],
      isInfinite: false,
      isAlternating: true,
      onComplete: () => print("combination complete"),
    );

    final sequence = SequenceEffect(
      effects: [move1, scale, combination],
      isInfinite: false,
      isAlternating: true,
    );
    sequence.onComplete = () => print("sequence complete");
    greenSquare.addEffect(sequence);
  }
}
