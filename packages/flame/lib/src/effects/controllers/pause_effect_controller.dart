import 'package:flame/src/effects/controllers/duration_effect_controller.dart';

/// A controller that keeps constant [progress] over [duration] seconds.
///
/// Since "progress" represents the "logical time" of an Effect, keeping the
/// progress constant over some time is equivalent to freezing in time or
/// pausing the effect for the prescribed duration.
///
/// This controller is best used in combination with other controllers. For
/// example, you can create a repeated controller where the progress changes
/// 0->1->0 over a short period of time, then pauses, and this sequence repeats.
class PauseEffectController extends DurationEffectController {
  PauseEffectController(double duration, {required double progress})
      : _progress = progress,
        super(duration);

  final double _progress;

  @override
  double get progress => _progress;
}
