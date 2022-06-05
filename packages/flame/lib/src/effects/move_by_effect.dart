import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/move_effect.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:vector_math/vector_math_64.dart';

/// A [MoveEffect] that moves its target by the specified offset vector.
///
/// This effect will move its target in a straight line to a new position that
/// is at an `offset` from the target's position at the start of the effect.
///
/// The `controller` can be used to change the timing of the movement: when the
/// move starts, how fast it is, whether the motion is uniform or not, and so
/// on. The [EffectController] can even be used to create oscillating or random
/// motions.
///
/// This effect applies incremental changes to the target's position, which
/// allows it to be combined with other [MoveEffect]s. When several
/// [MoveByEffect]s are applied to the same target simultaneously, the target
/// is moved by the vector sum of offsets from all effects.
class MoveByEffect extends MoveEffect {
  MoveByEffect(
    Vector2 offset,
    EffectController controller, {
    PositionProvider? target,
    void Function()? onComplete,
  })  : _offset = offset.clone(),
        super(controller, target, onComplete: onComplete);

  final Vector2 _offset;

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.position += _offset * dProgress;
  }

  @override
  double measure() => _offset.length;
}
