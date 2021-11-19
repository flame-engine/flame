import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class ColorEffectExample extends FlameGame with TapDetector {
  static const String description = '''
    In this example you can see the color of the sprite (the Flame logo) pulse
    towards a more green color and then back again. This is a non-interactive
    example.
  ''';

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final flameSprite = await loadSprite('flame.png');

    add(
      SpriteComponent(
        sprite: flameSprite,
        position: Vector2(300, 100),
        size: Vector2(149, 211),
      )..add(
          ColorEffect(
            color: const Color(0xFF00FF00),
            duration: 0.5,
            isInfinite: true,
            isAlternating: true,
          ),
        ),
    );
  }
}
