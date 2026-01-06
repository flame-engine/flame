import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

/// {@template flee_behavior}
/// Flee steering behavior.
/// {@endtemplate}
class FleeBehavior<Parent extends Steerable> extends SteeringBehavior<Parent> {
  /// {@macro flee_behavior}
  FleeBehavior(
    this.target, {
    required this.maxAcceleration,
    required this.panicDistance,
  });

  /// The target to flee from.
  final ReadOnlyPositionProvider target;

  /// The maximum acceleration of the entity.
  final double maxAcceleration;

  /// The maximum distance between the target and entity for the entity to
  /// panic.
  final double panicDistance;

  @override
  void update(double dt) {
    final distanceToTarget = target.position.distanceTo(parent.position);

    if (distanceToTarget < panicDistance) {
      steer(Flee(target, maxAcceleration: maxAcceleration), dt);
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {
    canvas.drawCircle((parent.size / 2).toOffset(), panicDistance, debugPaint);
    super.renderDebugMode(canvas);
  }
}
