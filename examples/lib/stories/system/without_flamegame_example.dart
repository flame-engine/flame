import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class NoFlameGameExample extends Game with KeyboardEvents {
  static const String description = '''
    This example showcases how to create a game without the FlameGame.
    It also briefly showcases how to act on keyboard events.
    Usage: Use W A S D to steer the rectangle.
  ''';

  static final Paint white = BasicPalette.white.paint();
  static const int speed = 200;

  Rect rect = const Rect.fromLTWH(0, 100, 100, 100);
  final Vector2 velocity = Vector2(0, 0);

  @override
  void update(double dt) {
    final displacement = velocity * (speed * dt);
    rect = rect.translate(displacement.x, displacement.y);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(rect, white);
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is RawKeyDownEvent;

    if (event.logicalKey == LogicalKeyboardKey.keyA) {
      velocity.x = isKeyDown ? -1 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      velocity.x = isKeyDown ? 1 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
      velocity.y = isKeyDown ? -1 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
      velocity.y = isKeyDown ? 1 : 0;
    }

    return super.onKeyEvent(event, keysPressed);
  }
}
