import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../../commons/square_component.dart';

class SizeEffectGame extends BaseGame with TapDetector {
  late SquareComponent square;
  bool grow = true;

  @override
  Future<void> onLoad() async {
    square = SquareComponent()
      ..position.setValues(200, 200)
      ..anchor = Anchor.center;
    onTap();
    add(square);
  }

  @override
  void onTap() {
    final s = grow ? 300.0 : 100.0;

    grow = !grow;
    square.add(
      SizeEffect(
        size: Vector2.all(s),
        speed: 250.0,
        curve: Curves.bounceInOut,
      ),
    );
  }
}
