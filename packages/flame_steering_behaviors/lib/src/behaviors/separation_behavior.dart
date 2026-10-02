import 'package:flame/components.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

/// {@template separation_behavior}
/// Separation steering behavior.
/// {@endtemplate}
class SeparationBehavior<Parent extends Steerable>(
  /// The entities to separate from.
  final Iterable<PositionComponent> entities, {

  /// The maximum distance at which the entity will separate.
  required final double maxDistance,

  /// The maximum acceleration the entity can apply to enable separation.
  required final double maxAcceleration,
}) extends SteeringBehavior<Parent> {
  @override
  void update(double dt) {
    steer(
      Separation(
        entities,
        maxDistance: maxDistance,
        maxAcceleration: maxAcceleration,
      ),
      dt,
    );
  }
}
