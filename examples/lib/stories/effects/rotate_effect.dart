import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

import '../../commons/square_component.dart';

class RotateEffectGame extends BaseGame with TapDetector {
  late SquareComponent square;

  @override
  Future<void> onLoad() async {
    square = SquareComponent()
      ..position.setValues(200, 200)
      ..anchor = Anchor.center;
    add(square);
  }

  @override
  void onTap() {
    square.addEffect(
      RotateEffect(
        angle: 2 * pi,
        isRelative: true,
        duration: 5.0,
        curve: Curves.bounceInOut,
      ),
    );
  }
}
