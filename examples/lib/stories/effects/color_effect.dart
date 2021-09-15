import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class ColorEffectGame extends FlameGame with TapDetector {
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
