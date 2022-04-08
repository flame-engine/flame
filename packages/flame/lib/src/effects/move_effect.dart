import 'package:vector_math/vector_math_64.dart';

import 'controllers/effect_controller.dart';
import 'effect.dart';
import 'effect_target.dart';
import 'measurable_effect.dart';
import 'move_by_effect.dart';
import 'move_to_effect.dart';
import 'provider_interfaces.dart';

/// Move a component to a new position.
///
/// The following constructors are provided:
///
///   - [MoveEffect.by] will move the target in a straight line to a new
///     position that is at an `offset` from the target's position at the onset
///     of the effect;
///
///   - [MoveEffect.to] will move the target in a straight line to the specified
///     coordinates;
///
/// This effect applies incremental changes to the component's position, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
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
