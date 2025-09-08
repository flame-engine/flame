import 'package:example/entities/entities.dart';
import 'package:example/entities/rectangle/behaviors/behaviors.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';

class Rectangle extends PositionedEntity with HasPaint {
  Rectangle({
    required double rotationSpeed,
    required Vector2 velocity,
    super.position,
    super.size,
  }) : super(
          anchor: Anchor.center,
          behaviors: [
            PropagatingCollisionBehavior(RectangleHitbox()),
            RectangleCollidingBehavior(),
            CircleCollidingBehavior(),
            ScreenCollidingBehavior(),
            MovingBehavior(velocity: velocity),
            RotatingBehavior(rotationSpeed: rotationSpeed),
            FreezingBehavior(),
          ],
        );

  final defaultColor = Colors.red.withValues(alpha: 0.8);

  @override
  void onMount() {
    paint.color = defaultColor;
    super.onMount();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Vector2.zero() & size, paint);
  }
}
