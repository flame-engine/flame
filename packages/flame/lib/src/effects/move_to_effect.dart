import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/move_by_effect.dart';
import 'package:flame/src/effects/move_effect.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:vector_math/vector_math_64.dart';

/// A [MoveEffect] that moves its target towards the given destination point.
///
/// This effect will move its target in a straight line towards the provided
/// `destination` position. The `controller` can be used to change the timing
/// of the movement: when it starts, the speed, whether the motion is uniform
/// or not, and so on. Refer to [EffectController] for details.
///
/// This effect applies incremental changes to the target's position, which
/// allows it to be combined with other [MoveEffect]s. Care must be taken to
/// compose effects in a sensible way. For example, applying a [MoveToEffect]
/// towards point A, and simultaneously another [MoveToEffect] towards point B
/// will end up moving the target towards point A+B. A more interesting
/// combination of move effects is to have a [MoveToEffect], together with one
/// or more [MoveByEffect]s that produce oscillating motion.
class MoveToEffect extends MoveEffect {
  MoveToEffect(
    Vector2 destination,
    EffectController controller, {
    PositionProvider? target,
    void Function()? onComplete,
  })  : _destination = destination.clone(),
        _offset = Vector2.zero(),
        super(controller, target, onComplete: onComplete);

  final Vector2 _destination;
  final Vector2 _offset;

  @override
  void onStart() {
    _offset.setFrom(_destination - target.position);
  }

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.position += _offset * dProgress;
  }

  @override
  double measure() => _offset.length;
}
