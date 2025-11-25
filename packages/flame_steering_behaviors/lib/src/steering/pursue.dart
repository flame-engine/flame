import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

/// {@template pursue}
/// Pursue steering algorithm.
/// {@endtemplate}
class Pursue extends SteeringCore {
  /// {@macro pursue}
  const Pursue(
    this.target, {
    required this.maxPrediction,
  });

  /// The target to pursue.
  final ReadOnlyPositionProvider target;

  /// The maximum prediction time.
  final double maxPrediction;

  @override
  Vector2 getSteering(Steerable parent) {
    final displacement = target.position - parent.position;
    final distance = displacement.length;

    final speed = parent.velocity.length;
    final double prediction;
    if (speed <= distance / maxPrediction) {
      prediction = maxPrediction;
    } else {
      prediction = distance / speed;
    }

    final explicitTarget = target.position.clone()
      ..add(parent.velocity)
      ..multiply(Vector2.all(prediction));

    return seek(parent, explicitTarget);
  }
}
