import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../../commons/square_component.dart';

final green = Paint()..color = const Color(0xAA338833);
final red = Paint()..color = const Color(0xAA883333);
final orange = Paint()..color = const Color(0xAABB6633);

SquareComponent makeSquare(Paint paint) {
  return SquareComponent()
    ..paint = paint
    ..position.setValues(100, 100);
}

class InfiniteEffectGame extends FlameGame with TapDetector {
  late SquareComponent greenSquare;
  late SquareComponent redSquare;
  late SquareComponent orangeSquare;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(greenSquare = makeSquare(green));
    add(redSquare = makeSquare(red));
    add(orangeSquare = makeSquare(orange));
  }

  @override
  void onTapUp(TapUpInfo info) {
    final p = info.eventPosition.game;

    greenSquare.clearEffects();
    redSquare.clearEffects();
    orangeSquare.clearEffects();

    greenSquare.add(
      MoveEffect(
        path: [p],
        speed: 250.0,
        curve: Curves.bounceInOut,
        isInfinite: true,
        isAlternating: true,
      ),
    );

    redSquare.add(
      SizeEffect(
        size: p,
        speed: 250.0,
        curve: Curves.easeInCubic,
        isInfinite: true,
        isAlternating: true,
      ),
    );

    orangeSquare.add(
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
