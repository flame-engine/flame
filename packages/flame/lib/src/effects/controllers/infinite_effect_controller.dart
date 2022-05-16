import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/effect.dart';

/// Effect controller that wraps a [child] effect controller and repeats it
/// infinitely.
class InfiniteEffectController extends EffectController {
  InfiniteEffectController(this.child) : super.empty();

  final EffectController child;

  @override
  bool get completed => false;

  @override
  double? get duration => double.infinity;

  @override
  double get progress => child.progress;

  @override
  bool get isRandom => child.isRandom;

  @override
  double advance(double dt) {
    var t = dt;
    for (;;) {
      t = child.advance(t);
      if (t == 0) {
        break;
      }
      child.setToStart();
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
  void setToStart() {
    child.setToStart();
  }

  @override
  void setToEnd() {
    child.setToEnd();
  }

  @override
  void onMount(Effect parent) => child.onMount(parent);
}
