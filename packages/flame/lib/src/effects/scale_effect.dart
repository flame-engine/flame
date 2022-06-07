import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/effect.dart';
import 'package:flame/src/effects/effect_target.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:vector_math/vector_math_64.dart';

/// Scale a component.
///
/// The following constructors are provided:
///
///   - [ScaleEffect.by] will scale the target by the given factor, relative to
///     its current scale;
///   - [ScaleEffect.to] will scale the target to the specified scale.
///
/// This effect applies incremental changes to the component's scale, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class ScaleEffect extends Effect with EffectTarget<ScaleProvider> {
  ScaleEffect.by(
    Vector2 scaleFactor,
    super.controller, {
    super.onComplete,
  }) : _scaleFactor = scaleFactor.clone();

  factory ScaleEffect.to(
    Vector2 targetScale,
    EffectController controller, {
    void Function()? onComplete,
  }) =>
      _ScaleToEffect(
        targetScale,
        controller,
        onComplete: onComplete,
      );

  final Vector2 _scaleFactor;
  late Vector2 _scaleDelta;

  @override
  void onStart() {
    _scaleDelta = Vector2(
      target.scale.x * (_scaleFactor.x - 1),
      target.scale.y * (_scaleFactor.y - 1),
    );
  }

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.scale += _scaleDelta * dProgress;
  }
}

/// Implementation class for [ScaleEffect.to]
class _ScaleToEffect extends ScaleEffect {
  final Vector2 _targetScale;

  _ScaleToEffect(
    Vector2 targetScale,
    EffectController controller, {
    void Function()? onComplete,
  })  : _targetScale = targetScale.clone(),
        super.by(
          Vector2.zero(),
          controller,
          onComplete: onComplete,
        );

  @override
  void onStart() {
    _scaleDelta = _targetScale - target.scale;
  }
}
