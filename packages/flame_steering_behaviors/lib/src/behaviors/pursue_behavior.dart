import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

/// {@template pursue_behavior}
/// Pursue steering behavior.
/// {@endtemplate}
class PursueBehavior<Parent extends Steerable>(
  /// The target to pursue.
  final PositionComponent target, {

  /// The range in which the goblin will pursue the player.
  required final double pursueRange,

  /// The maximum prediction time.
  final double maxPrediction = 1,
}) extends SteeringBehavior<Parent> {
  @override
  void update(double dt) {
    final distanceToTarget = target.distance(parent);

    if (distanceToTarget < pursueRange) {
      steer(Pursue(target, maxPrediction: maxPrediction), dt);
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {
    canvas.drawCircle(
      (parent.size / 2).toOffset(),
      pursueRange,
      debugPaint,
    );
    super.renderDebugMode(canvas);
  }
}
