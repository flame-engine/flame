import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flame/position.dart';

void main() {
  final game = MyGame();
  runApp(game.widget);
}

class MyGame extends Game with ScrollDetector {
  static const SPEED = 200;

  Position position = Position(0, 0);
  Position target;

  @override
  void onScroll(event) {
    target = position.minus(Position.fromOffset(event.scrollDelta));
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
      final dir = target.clone().minus(position).normalize();

      position.add(dir.times(SPEED * dt));
    }
  }
}
