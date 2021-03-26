import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flame/extensions.dart';

// TODO(luan) doesnt seem to be working, figure it out
class ScrollGame extends BaseGame with ScrollDetector {
  static const speed = 2000.0;
  final _size = Vector2.all(50);
  final _paint = BasicPalette.white.paint;

  Vector2 position = Vector2.all(100);
  Vector2? target;

  @override
  void onScroll(PointerScrollEvent event) {
    print(event.scrollDelta);
    target = position - event.scrollDelta.toVector2() * 10;
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
    if (target != null) {
      final dir = (target - position).normalized();
      position += dir * (speed * dt);
    }
  }
}
