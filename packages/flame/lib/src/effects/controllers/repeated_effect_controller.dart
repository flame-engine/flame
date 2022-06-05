import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/effect.dart';

/// Effect controller that repeats [child] controller a certain number of times.
///
/// The [repeatCount] must be positive, and [child] controller cannot be
/// infinite. The child controller will be reset after each iteration (except
/// the last).
class RepeatedEffectController extends EffectController {
  RepeatedEffectController(this.child, this.repeatCount)
      : assert(repeatCount > 0, 'repeatCount must be positive'),
        assert(!child.isInfinite, 'child cannot be infinite'),
        _remainingCount = repeatCount,
        super.empty();

  final EffectController child;
  final int repeatCount;

  /// How many iterations this controller has remaining. When this reaches 0
  /// the controller is considered completed.
  int get remainingIterationsCount => _remainingCount;
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
  bool get isRandom => child.isRandom;

  @override
  double advance(double dt) {
    var t = child.advance(dt);
    while (t > 0 && _remainingCount > 0) {
      assert(child.completed);
      _remainingCount--;
      if (_remainingCount != 0) {
        child.setToStart();
        t = child.advance(t);
      }
    }
    if (_remainingCount == 1 && child.completed) {
      _remainingCount--;
    }
    return t;
  }

  @override
  double recede(double dt) {
    if (_remainingCount == 0 && dt > 0) {
      // When advancing, we do not reset the child on last iteration. Hence,
      // if we recede from the end position the remaining count must be
      // adjusted.
      _remainingCount = 1;
      assert(child.completed);
    }
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

  @override
  void onMount(Effect parent) => child.onMount(parent);
}
