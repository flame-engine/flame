import 'package:flame/components.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

/// {@template separation}
/// Separation steering algorithm.
/// {@endtemplate}
class const Separation(
  /// The entities to separate from.
  final Iterable<PositionComponent> entities, {

  /// The maximum distance at which the entity will separate.
  required final double maxDistance,

  /// The maximum acceleration the entity can apply to enable separation.
  required final double maxAcceleration,
}) extends SteeringCore {
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
