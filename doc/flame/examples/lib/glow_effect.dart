import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';

import 'package:flutter/material.dart';

class GlowEffectExample extends FlameGame {
  @override
  Future<void> onLoad() async {
    final paint = Paint()..color = const Color(0xff39FF14);

    add(
      CircleComponent(
        radius: canvasSize.y / 4,
        position: canvasSize / 2,
        anchor: Anchor.center,
        paint: paint,
      )..add(
          GlowEffect(
            10.0,
            EffectController(
              duration: 2,
              infinite: true,
            ),
          ),
        ),
    );
  }
}
