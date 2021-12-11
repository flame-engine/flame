import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../../commons/ember.dart';

class ColorEffectExample extends FlameGame with TapDetector {
  static const String description = '''
    In this example we show how the `ColorEffect` can be used.
    Ember will constantly pulse in and out of a blue color.
  ''';

  late final SpriteComponent sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      Ember(
        position: Vector2(180, 230),
        size: Vector2.all(100),
      )..add(
          ColorEffect(
            Colors.blue,
            const Offset(
              0.0,
              0.8,
            ), // Means, applies from 0% to 80% of the color
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
