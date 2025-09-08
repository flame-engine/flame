import 'package:example/entities/entities.dart';
import 'package:flame/extensions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';

class RectangleCollidingBehavior
    extends CollisionBehavior<Rectangle, Rectangle> {
  final _collisionColor = Colors.yellow.withValues(alpha: 0.8);

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Rectangle other) {
    parent.paint.color = _collisionColor;
  }

  @override
  void onCollisionEnd(Rectangle other) {
    if (!isColliding) {
      parent.paint.color = parent.defaultColor;
    }
  }
}
