import 'effect_controller.dart';

/// Effect controller that wraps a [child] effect controller and repeats it
/// infinitely.
class InfiniteEffectController extends EffectController {
  InfiniteEffectController(this.child);

  final EffectController child;

  @override
  bool get isInfinite => true;

  @override
  bool get completed => false;

  @override
  double? get duration => null;

  @override
  double get progress => child.progress;

  @override
  double advance(double dt) {
    var t = dt;
    for (;;) {
      t = child.advance(t);
      if (t == 0) {
        break;
      }
      child.reset();
    }
    return 0;
  }

  @override
  double recede(double dt) {
    var t = dt;
    for (;;) {
      t = child.recede(t);
      if (t == 0) {
        break;
      }
      child.setToEnd();
    }
    return 0;
  }

  @override
  void setToEnd() {
    throw AssertionError('InfiniteEffectController does not have an end');
  }
}