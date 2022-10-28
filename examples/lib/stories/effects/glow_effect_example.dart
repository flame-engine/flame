import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class GlowEffectExample extends FlameGame with TapDetector {
  static const String description = '''
    In this example we show how the `GlowEffect` can be used.
  ''';

  late final SpriteComponent sprite;

  @override
  Future<void> onLoad() async {
    add(
      Ember(
        position: Vector2(180, 230),
        size: Vector2.all(100),
      )..add(
          GlowEffect(
            const MaskFilter.blur(BlurStyle.solid, 100.0),
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
