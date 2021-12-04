import 'package:vector_math/vector_math_64.dart';

import 'controllers/effect_controller.dart';
import 'transform2d_effect.dart';

/// Scale a component.
///
/// The following constructors are provided:
///
///   - [ScaleEffect.by] will scale the target in relation to it's current
///     scale;
///   - [ScaleEffect.to] will scale the target to the specified scale
///
/// This effect applies incremental changes to the component's scale, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class ScaleEffect extends Transform2DEffect {
  ScaleEffect.by(Vector2 offset, EffectController controller)
      : _offset = offset.clone(),
        super(controller);

  factory ScaleEffect.to(Vector2 targetScale, EffectController controller) =>
      _ScaleToEffect(targetScale, controller);

  Vector2 _offset;

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.scale += _offset * dProgress;
    super.apply(progress);
  }
}

/// Implementation class for [ScaleEffect.to]
class _ScaleToEffect extends ScaleEffect {
  final Vector2 _targetScale;

  _ScaleToEffect(Vector2 targetScale, EffectController controller)
      : _targetScale = targetScale.clone(),
        super.by(Vector2.zero(), controller);

  @override
  void onStart() {
    _offset = _targetScale - target.scale;
  }
}
