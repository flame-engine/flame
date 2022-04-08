import 'package:vector_math/vector_math_64.dart';

import 'controllers/effect_controller.dart';
import 'move_effect.dart';
import 'provider_interfaces.dart';

class MoveByEffect extends MoveEffect {
  MoveByEffect(
    Vector2 offset,
    EffectController controller, {
    PositionProvider? target,
  })  : _offset = offset.clone(),
        super(controller, target);

  final Vector2 _offset;

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.position += _offset * dProgress;
  }

  @override
  double measure() => _offset.length;
}
