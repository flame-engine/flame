import 'package:flame/effects.dart';

/// This simple effect, when attached to a component, will cause that component
/// to be removed from the game tree after `delay` seconds.
class RemoveEffect({
  double delay = 0.0,
  super.onComplete,
  super.key,
}) extends ComponentEffect {
  this
    : super(
        LinearEffectController(delay),
      );

  @override
  void apply(double progress) {
    if (progress == 1) {
      target.removeFromParent();
    }
  }
}
