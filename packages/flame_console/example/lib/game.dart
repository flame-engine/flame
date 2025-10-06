import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents {
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    world.addAll([
      RectangleComponent(
        position: Vector2(100, 0),
        size: Vector2(100, 100),
        paint: BasicPalette.white.paint(),
        children: [
          RectangleHitbox.relative(
            Vector2.all(0.8),
            parentSize: Vector2(100, 100),
          ),
          SequenceEffect(
            [
              MoveEffect.by(
                Vector2(-200, 0),
                LinearEffectController(1),
              ),
              MoveEffect.by(
                Vector2(200, 0),
                LinearEffectController(1),
              ),
            ],
            infinite: true,
          ),
        ],
      ),
      RectangleComponent(
        position: Vector2(200, 100),
        size: Vector2(100, 100),
        paint: BasicPalette.white.paint(),
        children: [
          RectangleHitbox.relative(
            Vector2.all(0.4),
            parentSize: Vector2(100, 100),
          ),
          SequenceEffect(
            [
              MoveEffect.by(
                Vector2(-200, 0),
                LinearEffectController(1),
              ),
              MoveEffect.by(
                Vector2(200, 0),
                LinearEffectController(1),
              ),
            ],
            infinite: true,
          ),
        ],
      ),
      RectangleComponent(
        position: Vector2(300, 200),
        size: Vector2(100, 100),
        paint: BasicPalette.white.paint(),
        children: [
          RectangleHitbox.relative(
            Vector2.all(0.2),
            parentSize: Vector2(100, 100),
          ),
          SequenceEffect(
            [
              MoveEffect.by(
                Vector2(-200, 0),
                LinearEffectController(1),
              ),
              MoveEffect.by(
                Vector2(200, 0),
                LinearEffectController(1),
              ),
            ],
            infinite: true,
          ),
        ],
      ),
    ]);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (!overlays.isActive('console')) {
      if (event is KeyDownEvent) {
        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.backquote) {
          overlays.add('console');
          return KeyEventResult.handled;
        }
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
