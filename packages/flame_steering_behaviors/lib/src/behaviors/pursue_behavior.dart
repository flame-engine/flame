import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

/// {@template pursue_behavior}
/// Pursue steering behavior.
/// {@endtemplate}
class PursueBehavior<Parent extends Steerable>
    extends SteeringBehavior<Parent> {
  /// {@macro pursue_behavior}
  PursueBehavior(
    this.target, {
    required this.pursueRange,
    this.maxPrediction = 1,
  });

  /// The target to pursue.
  final PositionComponent target;

  /// The maximum prediction time.
  final double maxPrediction;

  /// The range in which the goblin will pursue the player.
  final double pursueRange;

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
