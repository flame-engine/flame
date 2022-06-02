import 'package:flame/src/effects/controllers/linear_effect_controller.dart';
import 'package:flame/src/effects/effect.dart';

/// This simple effect, when attached to a component, will cause that component
/// to be removed from the game tree after `delay` seconds.
class RemoveEffect extends Effect {
  RemoveEffect({
    double delay = 0.0,
    void Function()? onComplete,
  }) : super(
          LinearEffectController(delay),
          onComplete: onComplete,
        );

  @override
  void apply(double progress) {
    if (progress == 1) {
      parent?.removeFromParent();
    }
  }
}
