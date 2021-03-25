import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MouseMovementGame extends BaseGame with MouseMovementDetector {
  static const speed = 200;
  static final Paint blue = Paint()..color = const Color(0xFF0000FF);
  static final Paint white = BasicPalette.white.paint;
  static final Vector2 objSize = Vector2.all(50);

  Vector2 position = Vector2(0, 0);
  Vector2? target;

  bool onTarget = false;

  @override
  void onMouseMove(PointerHoverEvent event) {
    target = event.localPosition.toVector2();
  }

  Rect _toRect() => position.toPositionedRect(objSize);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      _toRect(),
      onTarget ? blue : white,
    );
  }

  @override
  void update(double dt) {
    final target = this.target;
    super.update(dt);
    if (target != null) {
      onTarget = _toRect().contains(target.toOffset());

      if (!onTarget) {
        final dir = (target - position).normalized();
        position += dir * (speed * dt);
      }
    }
  }
}
