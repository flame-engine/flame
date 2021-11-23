import 'effect_controller.dart';

/// Effect controller that repeats [child] controller a certain number of times.
///
/// The [repeatCount] must be positive, and [child] controller cannot be
/// infinite. The child controller will be reset after each iteration (except
/// the last).
class RepeatedEffectController extends EffectController {
  RepeatedEffectController(this.child, this.repeatCount)
      : assert(repeatCount > 0, 'repeatCount must be positive'),
        assert(!child.isInfinite, 'child cannot be infinite'),
        _remainingCount = repeatCount;

  final EffectController child;
  final int repeatCount;
  int _remainingCount;

  @override
  double get progress => child.progress;

  @override
  bool get completed => _remainingCount == 0;

  @override
  double? get duration {
    final d = child.duration;
    return d == null ? null : d * repeatCount;
  }

  @override
  double advance(double dt) {
    var t = child.advance(dt);
    while (t > 0 && _remainingCount > 0) {
      _remainingCount--;
      child.setToStart();
      t = child.advance(t);
    }
    return t;
  }

  @override
  double recede(double dt) {
    var t = child.recede(dt);
    while (t > 0 && _remainingCount < repeatCount) {
      _remainingCount++;
      child.setToEnd();
      t = child.recede(t);
    }
    return t;
  }

  @override
  void setToStart() {
    _remainingCount = repeatCount;
    child.setToStart();
  }

  @override
  void setToEnd() {
    _remainingCount = 0;
    child.setToEnd();
  }
}
