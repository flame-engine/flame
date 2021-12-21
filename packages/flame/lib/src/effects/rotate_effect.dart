import 'controllers/effect_controller.dart';
import 'measurable_effect.dart';
import 'transform2d_effect.dart';

/// Rotate a component around its anchor.
///
/// Two constructors are provided:
///   - [RotateEffect.by] will rotate the target by the specified `angle`
///     relative to its orientation at the onset of the effect. For example,
///     rotating by `angle = tau/4` will turn the component 90° clockwise
///     relative to its initial direction;
///   - [RotateEffect.to] will rotate the target to the fixed orientation
///     specified by the `angle`. For example, rotating to `angle = tau/4` will
///     turn the component to look East regardless of its initial bearing.
///
/// This effect applies incremental changes to the component's angle, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class RotateEffect extends Transform2DEffect implements MeasurableEffect {
  RotateEffect.by(double angle, EffectController controller)
      : _angle = angle,
        super(controller);

  factory RotateEffect.to(double angle, EffectController controller) {
    return _RotateToEffect(angle, controller);
  }

  /// The magnitude of the effect: how much the target should turn as the
  /// progress goes from 0 to 1.
  double _angle;

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.angle += _angle * dProgress;
    super.apply(progress);
  }

  @override
  double measure() => _angle;
}

class _RotateToEffect extends RotateEffect {
  _RotateToEffect(double angle, EffectController controller)
      : _destinationAngle = angle,
        super.by(0, controller);

  final double _destinationAngle;

  @override
  void onStart() {
    _angle = _destinationAngle - target.angle;
  }
}
