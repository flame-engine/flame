import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/extensions/offset.dart';

void main() {
  final game = MyGame();
  runApp(game.widget);
}

class MyGame extends Game with ScrollDetector {
  static const SPEED = 200;

  Vector2 position = Vector2(0, 0);
  Vector2 target;

  @override
  void onScroll(event) {
    target = position - event.scrollDelta.toVector2();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(
        position.x,
        position.y,
        50,
        50,
      ),
      BasicPalette.white.paint,
    );
  }

  @override
  void update(double dt) {
    if (target != null) {
      final dir = (target - position).normalize();
      position += dir * (SPEED * dt);
    }
  }
}
