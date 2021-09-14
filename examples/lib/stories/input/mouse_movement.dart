import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class MouseMovementGame extends FlameGame with MouseMovementDetector {
  static const speed = 200;
  static final Paint _blue = BasicPalette.blue.paint();
  static final Paint _white = BasicPalette.white.paint();
  static final Vector2 objSize = Vector2.all(50);

  Vector2 position = Vector2(0, 0);
  Vector2? target;

  bool onTarget = false;

  @override
  void onMouseMove(PointerHoverInfo info) {
    target = info.eventPosition.game;
  }

  Rect _toRect() => position.toPositionedRect(objSize);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      _toRect(),
      onTarget ? _blue : _white,
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
