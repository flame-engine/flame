import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

import '../../commons/square_component.dart';

final green = Paint()..color = const Color(0xAA338833);

class SequenceEffectGame extends BaseGame with TapDetector {
  late SquareComponent greenSquare;

  @override
  Future<void> onLoad() async {
    add(
      greenSquare = SquareComponent()
        ..paint = green
        ..position = Vector2.all(100),
    );
  }

  @override
  void onTapUp(TapUpDetails details) {
    final currentTap = details.localPosition.toVector2();
    greenSquare.clearEffects();

    final move1 = MoveEffect(
      path: [currentTap],
      speed: 250.0,
      curve: Curves.bounceInOut,
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
    );

    final scale = ScaleEffect(
      size: currentTap,
      speed: 100.0,
      curve: Curves.easeInCubic,
    );

    final rotate = RotateEffect(
      angle: currentTap.angleTo(Vector2.all(100)),
      duration: 0.8,
      curve: Curves.decelerate,
    );

    final combination = CombinedEffect(
      effects: [move2, rotate],
      isAlternating: true,
      onComplete: () => print('combination complete'),
    );

    final sequence = SequenceEffect(
      effects: [move1, scale, combination],
      isAlternating: true,
    );
    sequence.onComplete = () => print('sequence complete');
    greenSquare.addEffect(sequence);
  }
}
