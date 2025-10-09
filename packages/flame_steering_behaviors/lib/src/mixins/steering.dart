import 'package:flame/extensions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';
import 'package:flutter/material.dart';

/// {@template steering}
/// Mixin that turns a [Behavior] into a steering behavior for a [Steerable].
/// {@endtemplate}
mixin Steering<T extends Steerable> on Behavior<T> {
  /// The current velocity of the parent entity.
  Vector2 get velocity => parent.velocity;

  /// Updates the velocity by the given linear acceleration from [steering].
  void steer(SteeringCore steering, double dt) {
    final linearAcceleration = steering.getSteering(parent)..scale(dt);
    velocity.add(linearAcceleration);

    if (velocity.length > parent.maxVelocity) {
      velocity.setFrom(velocity.normalized()..scale(parent.maxVelocity));
    }
  }

  @override
  @mustCallSuper
  void renderDebugMode(Canvas canvas) {
    canvas.drawLine(
      (parent.size / 2).toOffset(),
      velocity.toOffset(),
      debugPaint,
    );
  }
}
