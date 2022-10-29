import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: GlowEffectExample()));
}

class GlowEffectExample extends FlameGame with TapDetector {
  static const String description = '''
    In this example we show how the `GlowEffect` can be used.
  ''';

  @override
  Future<void> onLoad() async {
    final paint = Paint()
      ..color = const Color(0xff39FF14)
      ..style = PaintingStyle.stroke;

    add(
      CircleComponent(
        radius: 50,
        position: Vector2(300, 400),
        paint: paint,
      )..add(
          GlowEffect(
            10.0,
            EffectController(
              duration: 3,
              reverseDuration: 1.5,
              infinite: true,
            ),
          ),
        ),
    );
  }
}
