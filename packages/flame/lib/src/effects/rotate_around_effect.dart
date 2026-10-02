import 'package:flame/components.dart';
import 'package:flame/src/effects/effect.dart';
import 'package:flame/src/effects/effect_target.dart';
import 'package:flame/src/effects/measurable_effect.dart';
import 'package:flame/src/effects/provider_interfaces.dart';

/// Rotate a component around [center].
///
/// This effect rotates the target around a fixed point in its parent, specified
/// by [center]. The target's angle is by default aligned to the target's
/// angle around center, but this can be disabled by setting [alignRotation] to
/// false.
class RotateAroundEffect(
  /// The magnitude of the effect: how much the target should turn as the
  /// progress goes from 0 to 1.
  final double angle,
  super.controller, {

  /// The center (pivot point) of the rotation.
  required final Vector2 center,

  /// Whether the targets angle should be aligned to the target's current
  /// rotation around [center].
  final bool alignRotation = true,
  super.onComplete,
  super.key,
}) extends Effect
    with EffectTarget<PositionProvider>
    implements MeasurableEffect {
  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    if (alignRotation && target is AngleProvider) {
      (target as AngleProvider).angle += angle * dProgress;
    }
    target.position.rotate(angle * dProgress, center: center);
  }

  @override
  double measure() => angle;
}
