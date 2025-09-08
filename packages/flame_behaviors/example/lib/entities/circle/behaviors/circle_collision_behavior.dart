import 'package:example/entities/entities.dart';
import 'package:flame/extensions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';

class CircleCollisionBehavior extends CollisionBehavior<Circle, Circle> {
  final _collisionColor = Colors.green.withValues(alpha: 0.8);

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Circle other) {
    parent.paint.color = _collisionColor;
  }

  @override
  void onCollisionEnd(Circle other) {
    if (!isColliding) {
      parent.paint.color = parent.defaultColor;
    }
  }
}
