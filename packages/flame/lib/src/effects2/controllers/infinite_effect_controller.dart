import 'effect_controller.dart';

class InfiniteEffectController extends EffectController {
  InfiniteEffectController(EffectController child)
    : _child = child;

  final EffectController _child;

  @override
  bool get isInfinite => true;

  @override
  bool get completed => false;

  @override
  double? get duration => null;

  @override
  double get progress => _child.progress;

  @override
  double advance(double dt) {
    // FIXME
    if (goingForward) {}
    return dt;
  }

  @override
  void reverse() {
    super.reverse();
    _child.reverse();
  }
}