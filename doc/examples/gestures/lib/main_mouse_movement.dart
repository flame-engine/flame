import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flame/position.dart';

void main() {
  final game = MyGame();
  runApp(game.widget);
}

class MyGame extends Game with MouseMovementDetector {
  static const SPEED = 200;

  Position position = Position(0, 0);
  Position target;

  final Paint _blue = Paint()..color = const Color(0xFF0000FF);

  bool _onTarget = false;

  @override
  void onMouseMove(event) {
    target = Position.fromOffset(event.localPosition);
  }

  Rect _toRect() => Rect.fromLTWH(
        position.x,
        position.y,
        50,
        50,
      );

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      _toRect(),
      _onTarget ? _blue : BasicPalette.white.paint,
    );
  }

  @override
  void update(double dt) {
    if (target != null) {
      _onTarget = _toRect().contains(target.toOffset());

      if (!_onTarget) {
        final dir = target.clone().minus(position).normalize();

        position.add(dir.times(SPEED * dt));
      }
    }
  }
}
