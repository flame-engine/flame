import 'effect_controller.dart';

/// Simplest possible [EffectController], which supports an effect progressing
/// linearly over [duration] seconds.
///
/// The [duration] can be 0, in which case the effect will jump from 0 to 1
/// instantaneously.
///
class SimpleEffectController extends EffectController {
  SimpleEffectController([double duration = 0.0])
      : _duration = duration,
        _timer = 0.0,
        assert(duration >= 0, 'duration cannot be negative: $duration');

  final double _duration;
  double _timer;

  @override
  double? get duration => _duration;

  @override
  bool get completed => _timer >= _duration;

  // If duration is 0, `completed` will always be true, avoiding division by 0.
  @override
  double get progress => completed? 1 : (_timer / _duration);

  @override
  double advance(double dt) {
    var extraTime = 0.0;
    if (goingForward) {
      _timer += dt;
      if (_timer > _duration) {
        extraTime = _timer - _duration;
        _timer = _duration;
      }
    } else {
      _timer -= dt;
      if (_timer < 0) {
        extraTime = 0 - _timer;
        _timer = 0;
      }
    }
    return extraTime;
  }

  @override
  void reset() {
    super.reset();
    _timer = 0;
  }
}
