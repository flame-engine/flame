import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MouseMovementGame extends BaseGame with MouseMovementDetector {
  static const speed = 200;
  static final Paint _blue = BasicPalette.blue.paint();
  static final Paint _white = BasicPalette.white.paint();
  static final Vector2 _size = Vector2.all(50);

  Vector2 position = Vector2(0, 0);
  Vector2 target;

  bool _onTarget = false;

  @override
  void onMouseMove(PointerHoverEvent event) {
    target = event.localPosition.toVector2();
  }

  Rect _toRect() => position.toPositionedRect(_size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      _toRect(),
      _onTarget ? _blue : _white,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (target != null) {
      _onTarget = _toRect().contains(target.toOffset());

      if (!_onTarget) {
        final dir = (target - position).normalized();
        position += dir * (speed * dt);
      }
    }
  }
}
