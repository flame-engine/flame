import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

import '../../commons/square_component.dart';

final green = Paint()..color = const Color(0xAA338833);
final red = Paint()..color = const Color(0xAA883333);
final orange = Paint()..color = const Color(0xAABB6633);

SquareComponent makeSquare(Paint paint) {
  return SquareComponent()
    ..paint = paint
    ..position = Vector2.all(100);
}

class InfiniteEffectGame extends BaseGame with TapDetector {
  late SquareComponent greenSquare;
  late SquareComponent redSquare;
  late SquareComponent orangeSquare;

  @override
  Future<void> onLoad() async {
    add(greenSquare = makeSquare(green));
    add(redSquare = makeSquare(red));
    add(orangeSquare = makeSquare(orange));
  }

  @override
  void onTapUp(TapUpDetails details) {
    final p = details.localPosition.toVector2();

    greenSquare.clearEffects();
    redSquare.clearEffects();
    orangeSquare.clearEffects();

    greenSquare.addEffect(
      MoveEffect(
        path: [p],
        speed: 250.0,
        curve: Curves.bounceInOut,
        isInfinite: true,
        isAlternating: true,
      ),
    );

    redSquare.addEffect(
      ScaleEffect(
        size: p,
        speed: 250.0,
        curve: Curves.easeInCubic,
        isInfinite: true,
        isAlternating: true,
      ),
    );

    orangeSquare.addEffect(
      RotateEffect(
        angle: (p.x + p.y) % (2 * pi),
        speed: 1.0, // Radians per second
        curve: Curves.easeInOut,
        isInfinite: true,
        isAlternating: true,
      ),
    );
  }
}
