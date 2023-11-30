import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class ColorEffectExample extends FlameGame with TapDetector {
  static const String description = '''
    In this example we show how the `ColorEffect` can be used.
    Ember will constantly pulse in and out of a blue color.
  ''';

  late final SpriteComponent sprite;

  @override
  Future<void> onLoad() async {
    add(
      Ember(
        position: Vector2(180, 230),
        size: Vector2.all(100),
      )..add(
          ColorEffect(
            Colors.blue,
            EffectController(
              duration: 1.5,
              reverseDuration: 1.5,
              infinite: true,
            ),
            // Means, applies from 0% to 80% of the color
            opacityTo: 0.8,
          ),
        ),
    );
  }
}
