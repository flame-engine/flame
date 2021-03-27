import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

import '../../commons/square_component.dart';

class ScaleEffectGame extends BaseGame with TapDetector {
  late SquareComponent square;
  bool grow = true;

  @override
  Future<void> onLoad() async {
    add(
      square = SquareComponent()
        ..position = Vector2.all(200)
        ..anchor = Anchor.center,
    );
  }

  @override
  void onTap() {
    final s = grow ? 300.0 : 100.0;

    grow = !grow;
    square.addEffect(
      ScaleEffect(
        size: Vector2.all(s),
        speed: 250.0,
        curve: Curves.bounceInOut,
      ),
    );
  }
}
