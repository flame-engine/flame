import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

import '../../commons/square_component.dart';

class RotateEffectGame extends BaseGame with TapDetector {
  SquareComponent square;

  RotateEffectGame() {
    add(
      square = SquareComponent()
        ..position = Vector2.all(200)
        ..anchor = Anchor.center,
    );
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
