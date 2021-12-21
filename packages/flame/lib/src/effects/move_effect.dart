import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import 'controllers/effect_controller.dart';
import 'measurable_effect.dart';
import 'transform2d_effect.dart';

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
class MoveEffect extends Transform2DEffect implements MeasurableEffect {
  MoveEffect.by(Vector2 offset, EffectController controller)
      : vector = offset.clone(),
        super(controller);

  factory MoveEffect.to(Vector2 destination, EffectController controller) =>
      _MoveToEffect(destination, controller);

  @protected
  Vector2 vector;

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.position += vector * dProgress;
    super.apply(progress);
  }

  @override
  double measure() => vector.length;
}

/// Implementation class for [MoveEffect.to]
class _MoveToEffect extends MoveEffect {
  _MoveToEffect(Vector2 destination, EffectController controller)
      : _destination = destination.clone(),
        super.by(Vector2.zero(), controller);

  final Vector2 _destination;

  @override
  void onStart() {
    vector = _destination - target.position;
  }
}
