import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
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
      ..position.setValues(100, 100);

    redSquare = SquareComponent()
      ..paint = red
      ..position.setValues(100, 100);

    add(greenSquare);
    add(redSquare);
  }

  @override
  void onTapUp(TapUpInfo info) {
    greenSquare.clearEffects();
    final currentTap = info.eventPosition.game;

    final move = MoveEffect(
      path: [
        currentTap,
        currentTap - Vector2(50, 20),
        currentTap + Vector2.all(30),
      ],
      isAlternating: true,
      duration: 4.0,
      curve: Curves.bounceInOut,
      preOffset: 0.6,
    );

    final scale = SizeEffect(
      size: currentTap,
      speed: 200.0,
      curve: Curves.linear,
      isAlternating: true,
      postOffset: 1.0,
    );

    final rotate = RotateEffect(
      angle: currentTap.angleTo(Vector2.all(100)),
      duration: 3,
      curve: Curves.decelerate,
      isAlternating: true,
      preOffset: 1.0,
      postOffset: 1.0,
    );

    final combination = CombinedEffect(
      effects: [move, rotate, scale],
    );
    greenSquare.add(combination);
  }
}
