import 'dart:math';

import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

/// {@template wander_behavior}
/// Wander steering behavior.
/// {@endtemplate}
class WanderBehavior<Parent extends Steerable>({
  /// The distance to the circle center of the next target.
  required final double circleDistance,

  /// The rate at which the wander angle can change in radians.
  required final double maximumAngle,
  required double startingAngle,
  Random? random,
}) extends SteeringBehavior<Parent> {
  /// The current wander angle in radians.
  double get angle => _angle;
  double _angle = startingAngle;

  /// The random number generator used to calculate the next wander [angle].
  final Random random = random ?? Random();

  @override
  void update(double dt) {
    steer(
      Wander(
        circleDistance: circleDistance,
        maximumAngle: maximumAngle,
        angle: _angle,
        onNewAngle: (angle) => _angle = angle,
        random: random,
      ),
      dt,
    );
  }
}
