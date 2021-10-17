import 'package:vector_math/vector_math_64.dart';

import 'flame_animation_controller.dart';
import 'transform2d_effect.dart';

class NewMoveEffect extends Transform2DEffect {
  NewMoveEffect.to({
    required Vector2 destination,
    required FlameAnimationController controller,
  })  : _absolute = true,
        _offset = destination.clone(),
        _lastProgress = 0,
        super(controller: controller);

  NewMoveEffect.by({
    required Vector2 offset,
    required FlameAnimationController controller,
  })  : _absolute = false,
        _offset = offset.clone(),
        _lastProgress = 0,
        super(controller: controller);

  final bool _absolute;
  Vector2 _offset;
  double _lastProgress;

  @override
  void onStart() {
    if (_absolute) {
      _offset -= target.position;
    }
  }

  @override
  void apply(double progress) {
    final dProgress = progress - _lastProgress;
    target.position += _offset * dProgress;
    _lastProgress = progress;
  }
}
