import 'package:flame/components.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/effect.dart';
import 'package:flame/src/effects/effect_target.dart';
import 'package:flame/src/effects/provider_interfaces.dart';

/// Change the size of a component over time.
///
/// This effect applies incremental changes to the component's size, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class SizeEffect extends Effect with EffectTarget<SizeProvider> {
  /// This constructor will create an effect that sets the size in relation to
  /// the [PositionComponent]'s  current size, for example if the [offset] is
  /// set to `Vector2(10, -10)` and the size of the affected component is
  /// `Vector2(100, 100)` at the start of the affected the effect will peak when
  /// the size is `Vector2(110, 90)`, if there is nothing else affecting the
  /// size at the same time.
  SizeEffect.by(
    Vector2 offset,
    EffectController controller, {
    SizeProvider? target,
  })  : _offset = offset.clone(),
        super(controller) {
    this.target = target;
  }

  /// This constructor will create an effect that sets the size to the absolute
  /// size that is defined by [targetSize].
  /// For example if the [targetSize] is set to `Vector2(200, 200)` and the size
  /// of the affected component is `Vector2(100, 100)` at the start of the
  /// affected the effect will peak when the size is `Vector2(200, 100)`, if
  /// there is nothing else affecting the size at the same time.
  factory SizeEffect.to(Vector2 targetSize, EffectController controller) =>
      _SizeToEffect(targetSize, controller);

  Vector2 _offset;

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.size += _offset * dProgress;
    target.size.clampScalar(0, double.infinity);
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
