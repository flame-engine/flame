import 'effect_controller.dart';
import 'standard_effect_controller.dart';

/// Simplest possible [EffectController], which supports an effect progressing
/// linearly over [duration] seconds.
///
/// The [duration] can be 0, in which case the effect will jump from 0 to 1
/// instantaneously.
///
/// The [delay] parameter allows to delay the start of the effect by the
/// specified number of seconds.
///
/// See also: [StandardEffectController]
class SimpleEffectController extends EffectController {
  SimpleEffectController({
    this.duration = 0.0,
    this.delay = 0.0,
  })  : assert(duration >= 0, 'duration cannot be negative: $duration'),
        assert(delay >= 0, 'delay cannot be negative: $delay');

  final double duration;
  final double delay;
  double _timer = 0.0;

  @override
  bool get started => _timer >= delay;

  @override
  bool get completed => _timer >= delay + duration;

  @override
  bool get isInfinite => false;

  @override
  double get progress {
    // If duration == 0, then `completed == started`, and the middle case
    // (which divides by duration) cannot occur.
    return completed
        ? 1
        : started
            ? (_timer - delay) / duration
            : 0;
  }

  @override
  void update(double dt) {
    _timer += dt;
  }

  @override
  void reset() {
    _timer = 0;
  }
}
