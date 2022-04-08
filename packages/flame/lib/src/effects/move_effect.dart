import 'package:vector_math/vector_math_64.dart';

import 'controllers/effect_controller.dart';
import 'effect.dart';
import 'effect_target.dart';
import 'measurable_effect.dart';
import 'move_by_effect.dart';
import 'move_to_effect.dart';
import 'provider_interfaces.dart';

/// Base class for effects that affect the `position` of their targets.
///
/// The main purpose of this class is for reflection, for example to select
/// all effects on the target that are of "move" type.
///
/// Factory constructors [MoveEffect.by] and [MoveEffect.to] are also provided,
/// but they may be deprecated in the future.
abstract class MoveEffect extends Effect
    with EffectTarget<PositionProvider>
    implements MeasurableEffect {
  MoveEffect(EffectController controller, PositionProvider? target)
      : super(controller) {
    this.target = target;
  }

  factory MoveEffect.by(
    Vector2 offset,
    EffectController controller, {
    PositionProvider? target,
  }) =>
      MoveByEffect(offset, controller, target: target);

  factory MoveEffect.to(
    Vector2 destination,
    EffectController controller, {
    PositionProvider? target,
  }) =>
      MoveToEffect(destination, controller, target: target);
}
