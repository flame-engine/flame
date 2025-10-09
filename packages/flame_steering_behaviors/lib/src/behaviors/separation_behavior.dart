import 'package:flame/components.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

/// {@template separation_behavior}
/// Separation steering behavior.
/// {@endtemplate}
class SeparationBehavior<Parent extends Steerable>
    extends SteeringBehavior<Parent> {
  /// {@macro separation_behavior}
  SeparationBehavior(
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
