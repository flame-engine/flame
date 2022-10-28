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
    add(
      CircleComponent(
        radius: 50,
        position: Vector2(280, 280),
        paint: Paint()..color = const Color(0xff39FF14),
      )..add(
          GlowEffect(
            BlurStyle.outer,
            50.0,
            EffectController(
              duration: 1.5,
              reverseDuration: 1.5,
              infinite: true,
            ),
          ),
        ),
    );
  }
}
