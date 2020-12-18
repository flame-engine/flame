import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/extensions/offset.dart';

void main() {
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

class MyGame extends BaseGame with MouseMovementDetector {
  static const SPEED = 200;

  Vector2 position = Vector2(0, 0);
  Vector2 target;

  final Paint _blue = Paint()..color = const Color(0xFF0000FF);

  bool _onTarget = false;

  @override
  void onMouseMove(event) {
    target = event.localPosition.toVector2();
  }

  Rect _toRect() => Rect.fromLTWH(
        position.x,
        position.y,
        50,
        50,
      );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      _toRect(),
      _onTarget ? _blue : BasicPalette.white.paint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (target != null) {
      _onTarget = _toRect().contains(target.toOffset());

      if (!_onTarget) {
        final dir = (target - position).normalized();
        position += dir * (SPEED * dt);
      }
    }
  }
}
