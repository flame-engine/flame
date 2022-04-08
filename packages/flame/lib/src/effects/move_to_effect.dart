import 'package:vector_math/vector_math_64.dart';

import 'controllers/effect_controller.dart';
import 'move_effect.dart';
import 'provider_interfaces.dart';

/// Implementation class for [MoveEffect.to]
class MoveToEffect extends MoveEffect {
  MoveToEffect(
    Vector2 destination,
    EffectController controller, {
    PositionProvider? target,
  })  : _destination = destination.clone(),
        _offset = Vector2.zero(),
        super(controller, target);

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
