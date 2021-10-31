
import 'effect.dart';
import 'simple_effect_controller.dart';

/// This simple effect, when attached to a component will cause that component
/// to be removed from the game tree and destroyed after `delay` seconds.
class DestroyEffect extends Effect {
  DestroyEffect({double delay = 0.0})
    : super(SimpleEffectController(delay: delay));

  @override
  void apply(double progress) {
    if (progress == 1) {
      parent?.removeFromParent();
    }
  }
}
