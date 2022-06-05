import 'package:flame/src/anchor.dart';
import 'package:flame/src/effects/anchor_effect.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:vector_math/vector_math_64.dart';

/// An [AnchorEffect] that changes its target's anchor by the specified offset.
///
/// This effect will move the anchor in a straight line to a new position that
/// is at an `offset` from the target's anchor at the start of the effect.
///
/// The `controller` can be used to change the timing of the movement: when the
/// move starts, how fast it is, whether the motion is uniform or not, and so
/// on. The [EffectController] can even be used to create oscillating or random
/// motions.
///
/// This effect applies incremental changes to the target's position, which
/// allows it to be combined with other [AnchorEffect]s. When several
/// [AnchorByEffect]s are applied to the same target simultaneously, the anchor
/// is moved by the vector sum of offsets from all effects.
class AnchorByEffect extends AnchorEffect {
  AnchorByEffect(
    Vector2 offset,
    EffectController controller, {
    AnchorProvider? target,
    void Function()? onComplete,
  })  : _offset = offset.clone(),
        super(controller, target, onComplete: onComplete);

  final Vector2 _offset;

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.anchor = Anchor(
      target.anchor.x + _offset.x * dProgress,
      target.anchor.y + _offset.y * dProgress,
    );
  }

  @override
  double measure() => _offset.length;
}
