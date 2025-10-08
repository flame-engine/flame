import 'package:flame/extensions.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

/// {@template steering_core}
/// Base class for all steering behaviors.
/// {@endtemplate}
abstract class SteeringCore {
  /// {@macro steering_core}
  const SteeringCore();

  /// Calculates the next target position to steer towards.
  Vector2 getSteering(Steerable parent);

  /// Seek steering behavior.
  Vector2 seek(Steerable parent, Vector2 target) {
    final acceleration = (target - parent.position)..normalize();
    return acceleration * parent.maxVelocity;
  }
}
