import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../../commons/square_component.dart';

class RotateEffectGame extends FlameGame with TapDetector {
  late SquareComponent square;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    square = SquareComponent(position: Vector2.all(200));
    add(square);
  }

  @override
  void onTap() {
    square.add(
      RotateEffect(
        angle: 2 * pi,
        isRelative: true,
        duration: 5.0,
        curve: Curves.bounceInOut,
      ),
    );
  }
}
