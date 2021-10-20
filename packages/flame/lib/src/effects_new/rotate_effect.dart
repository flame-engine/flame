import 'flame_animation_controller.dart';
import 'transform2d_effect.dart';

/// Rotate a component around its anchor.
///
/// Two constructors are provided: [RotateEffect.by] will rotate the target by
/// the specified `angle` relative to its orientation at the onset of the
/// effect; at the same time [RotateEffect.to] will rotate the target from its
/// current orientation at the onset of the effect to the fixed direction
/// specified by the `angle`.
///
/// This effect applies incremental changes to the component's angle, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class RotateEffect extends Transform2DEffect {
  RotateEffect.by(double angle, {
    required FlameAnimationController controller,
  })  : _angle = angle,
        _relative = true,
        _lastProgress = 0,
        super(controller: controller);

  RotateEffect.to(double angle, {
    required FlameAnimationController controller,
  })  : _angle = angle,
        _relative = false,
        _lastProgress = 0,
        super(controller: controller);

  final bool _relative;
  double _angle;
  double _lastProgress;

  @override
  void onStart() {
    if (!_relative) {
      _angle -= target.angle;
    }
  }

  @override
  void apply(double progress) {
    final dProgress = progress - _lastProgress;
    target.angle += _angle * dProgress;
    _lastProgress = progress;
  }

  @override
  void reset() {
    super.reset();
    _lastProgress = 0;
  }
}
