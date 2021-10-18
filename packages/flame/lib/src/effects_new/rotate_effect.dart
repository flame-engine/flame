import 'flame_animation_controller.dart';
import 'transform2d_effect.dart';

/// Move a component to a new point that is at an `offset` from the component's
/// position at the onset of the effect.
///
/// This effect applies incremental changes to the component's coordinates, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class RotateEffect extends Transform2DEffect {
  RotateEffect({
    required double angle,
    required FlameAnimationController controller,
  })  : _angle = angle,
        _lastProgress = 0,
        super(controller: controller);

  final double _angle;
  double _lastProgress;

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