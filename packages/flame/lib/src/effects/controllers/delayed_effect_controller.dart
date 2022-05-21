import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/effect.dart';

/// An effect controller that waits for [delay] seconds before running the
/// child controller. While waiting, the progress will be reported at 0.
class DelayedEffectController extends EffectController {
  DelayedEffectController(EffectController child, {required this.delay})
      : assert(delay >= 0, 'Delay must be non-negative: $delay'),
        _child = child,
        _timer = 0,
        super.empty();

  final EffectController _child;
  final double delay;
  double _timer;

  @override
  bool get isRandom => _child.isRandom;

  @override
  bool get started => _timer == delay;

  @override
  bool get completed => started && _child.completed;

  @override
  double get progress => started ? _child.progress : 0;

  @override
  double? get duration {
    final d = _child.duration;
    return d == null ? null : d + delay;
  }

  @override
  double advance(double dt) {
    if (_timer == delay) {
      return _child.advance(dt);
    }
    _timer += dt;
    if (_timer > delay) {
      final t = _child.advance(_timer - delay);
      _timer = delay;
      return t;
    } else {
      return 0;
    }
  }

  @override
  double recede(double dt) {
    if (_timer == delay) {
      _timer -= _child.recede(dt);
    } else {
      _timer -= dt;
    }
    if (_timer < 0) {
      final leftoverTime = -_timer;
      _timer = 0;
      return leftoverTime;
    }
    return 0;
  }

  @override
  void setToStart() {
    _timer = 0;
  }

  @override
  void setToEnd() {
    _timer = delay;
    _child.setToEnd();
  }

  @override
  void onMount(Effect parent) => _child.onMount(parent);
}
