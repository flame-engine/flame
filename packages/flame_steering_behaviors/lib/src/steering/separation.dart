import 'package:flame/components.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

/// {@template separation}
/// Separation steering algorithm.
/// {@endtemplate}
class Separation extends SteeringCore {
  /// {@macro separation}
  const Separation(
    this.entities, {
    required this.maxDistance,
    required this.maxAcceleration,
  });

  /// The maximum distance at which the entity will separate.
  final double maxDistance;

  /// The maximum acceleration the entity can apply to enable separation.
  final double maxAcceleration;

  /// The entities to separate from.
  final Iterable<PositionComponent> entities;

  @override
  Vector2 getSteering(Steerable parent) {
    final acceleration = Vector2.zero();
    for (final entity in entities) {
      if (entity == parent) {
        continue;
      }
      final direction = entity.position - parent.position;
      final dist = direction.length;
      if (dist < maxDistance) {
        final strength =
            maxAcceleration *
            (maxDistance - dist) /
            (maxDistance - entity.size.x - parent.size.x);

        direction.normalize();
        acceleration.add(direction * strength);
      }
    }
    return acceleration;
  }
}
