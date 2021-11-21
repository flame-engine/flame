import 'effect_controller.dart';

/// A controller that grows linearly from 0 to 1 over [duration] seconds.
///
/// The [duration] can also be 0, in which case the effect will jump from 0 to 1
/// instantaneously.
class LinearEffectController extends EffectController {
  LinearEffectController(double duration)
      : _duration = duration,
        _timer = 0.0,
        assert(duration >= 0, 'duration cannot be negative: $duration');

  final double _duration;
  double _timer;

  @override
  double? get duration => _duration;

  @override
  bool get completed => _timer == _duration;

  // If duration is 0, `completed` will be true, and division by 0 avoided.
  @override
  double get progress => completed? 1 : (_timer / _duration);

  @override
  double advance(double dt) {
    var leftoverTime = 0.0;
    if (goingForward) {
      _timer += dt;
      if (_timer > _duration) {
        leftoverTime = _timer - _duration;
        _timer = _duration;
      }
    } else {
      _timer -= dt;
      if (_timer < 0) {
        leftoverTime = 0 - _timer;
        _timer = 0;
      }
    }
    return leftoverTime;
  }

  @override
  void reset() {
    super.reset();
    _timer = 0;
  }
}
