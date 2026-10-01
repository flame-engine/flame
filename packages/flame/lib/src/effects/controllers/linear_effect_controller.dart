import 'package:flame/src/effects/controllers/duration_effect_controller.dart';

/// A controller that grows linearly from 0 to 1 over [duration] seconds.
///
/// The [duration] can also be 0, in which case the effect will jump from 0 to 1
/// instantaneously.
class LinearEffectController(super.duration) extends DurationEffectController {
  @override
  double get progress => completed ? 1 : (timer / duration);
}
