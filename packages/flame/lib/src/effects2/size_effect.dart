import '../../components.dart';
import '../../extensions.dart';
import 'component_effect.dart';
import 'effect_controller.dart';

/// Change the size of a component over time.
///
/// The following constructors are provided:
///
///   - [SizeEffect.by] will set the size in relation to it's current size;
///   - [SizeEffect.to] will set the size to the specified size
///
/// This effect applies incremental changes to the component's size, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class SizeEffect extends ComponentEffect<PositionComponent> {
  SizeEffect.by(Vector2 offset, EffectController controller)
      : _offset = offset.clone(),
        super(controller);

  factory SizeEffect.to(Vector2 targetSize, EffectController controller) =>
      _SizeToEffect(targetSize, controller);

  Vector2 _offset;

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.size += _offset * dProgress;
    super.apply(progress);
  }
}

/// Implementation class for [SizeEffect.to]
class _SizeToEffect extends SizeEffect {
  final Vector2 _targetSize;

  _SizeToEffect(Vector2 targetSize, EffectController controller)
      : _targetSize = targetSize.clone(),
        super.by(Vector2.zero(), controller);

  @override
  void onStart() {
    _offset = _targetSize - target.size;
  }
}
