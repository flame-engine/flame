import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flame/extensions.dart';

void main() {
  final game = MyGame();
  runApp(
    GameWidget(
      game: game,
    ),
  );
}

class MyGame extends BaseGame with ScrollDetector {
  static const speed = 200.0;

  Vector2 position = Vector2(0, 0);
  Vector2 target;

  @override
  void onScroll(event) {
    target = position - event.scrollDelta.toVector2();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
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
    super.update(dt);
    if (target != null) {
      final dir = (target - position).normalized();
      position += dir * speed * dt;
    }
  }
}
