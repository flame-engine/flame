import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';

/// {@template steerable}
/// Mixin that makes an [Entity] steerable.
/// {@endtemplate}
mixin Steerable on EntityMixin, PositionComponent {
  /// The max velocity of the entity.
  ///
  /// Used for clamping the [velocity] distance.
  double get maxVelocity;

  /// The current velocity of the entity.
  final velocity = Vector2.zero();

  @override
  @mustCallSuper
  void update(double dt) {
    final velocityDelta = velocity * dt;
    position.add(velocityDelta);
    velocity.sub(velocityDelta);

    super.update(dt);
  }
}
