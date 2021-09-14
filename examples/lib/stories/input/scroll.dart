import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class ScrollGame extends FlameGame with ScrollDetector {
  static const speed = 2000.0;
  final _size = Vector2.all(50);
  final _paint = BasicPalette.white.paint();

  Vector2 position = Vector2.all(100);
  Vector2? target;

  @override
  void onScroll(PointerScrollInfo info) {
    target = position + info.scrollDelta.game * 5;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(position.toPositionedRect(_size), _paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final target = this.target;
    final ds = speed * dt;
    if (target != null) {
      if (position != target) {
        final diff = target - position;
        if (diff.length < ds) {
          position.setFrom(target);
        } else {
          diff.scaleTo(ds);
          position.setFrom(position + diff);
        }
      }
    }
  }
}
