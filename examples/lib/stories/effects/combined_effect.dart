import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

import '../../commons/square_component.dart';

final green = Paint()..color = const Color(0xAA338833);
final red = Paint()..color = const Color(0xAA883333);

class CombinedEffectGame extends BaseGame with TapDetector {
  late SquareComponent greenSquare, redSquare;

  @override
  Future<void> onLoad() async {
    greenSquare = SquareComponent()
      ..paint = green
      ..position = Vector2.all(100);

    redSquare = SquareComponent()
      ..paint = red
      ..position = Vector2.all(100);

    add(greenSquare);
    add(redSquare);
  }

  @override
  void onTapUp(TapUpDetails details) {
    greenSquare.clearEffects();
    final currentTap = details.localPosition.toVector2();

    final move = MoveEffect(
      path: [
        currentTap,
        currentTap - Vector2(50, 20),
        currentTap + Vector2.all(30),
      ],
      duration: 4.0,
      curve: Curves.bounceInOut,
    );

    final scale = ScaleEffect(
      size: currentTap,
      speed: 200.0,
      curve: Curves.linear,
      isAlternating: true,
    );

    final rotate = RotateEffect(
      angle: currentTap.angleTo(Vector2.all(100)),
      duration: 3,
      curve: Curves.decelerate,
    );

    final combination = CombinedEffect(
      effects: [move, rotate, scale],
      isAlternating: true,
      offset: 0.5,
      onComplete: () => print('onComplete callback'),
    );
    greenSquare.addEffect(combination);
  }
}
