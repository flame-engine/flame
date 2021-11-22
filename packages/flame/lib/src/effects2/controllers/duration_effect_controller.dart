import 'package:meta/meta.dart';

import 'effect_controller.dart';

/// Abstract class for an effect controller that has a predefined [duration].
///
/// This effect controller cannot be used directly, instead it serves as base
/// for some other effect controller classes.
///
/// The primary functionality offered by this class is the [timer] property,
/// which keeps track of how much time has passed within this controller. The
/// effect controller will be considered [completed] when the timer reaches the
/// [duration] value.
abstract class DurationEffectController extends EffectController {
  DurationEffectController(double duration)
      : assert(duration >= 0, 'Duration cannot be negative: $duration'),
        _duration = duration,
        _timer = 0;

  double _duration;
  double _timer;

  @override
  double get duration => _duration;

  @protected
  set duration(double value) => _duration = value;

  @protected
  double get timer => _timer;

  @override
  bool get completed => _timer == _duration;

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
