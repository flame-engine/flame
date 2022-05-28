import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/effect.dart';

/// An effect controller that executes a list of other controllers one after
/// another.
class SequenceEffectController extends EffectController {
  SequenceEffectController(List<EffectController> controllers)
      : assert(controllers.isNotEmpty, 'List of controllers cannot be empty'),
        assert(
          !controllers.any((c) => c.isInfinite),
          'Children controllers cannot be infinite',
        ),
        children = controllers,
        _currentIndex = 0,
        super.empty();

  /// Individual controllers in the sequence.
  final List<EffectController> children;

  /// The index of the controller currently being executed. This starts with 0,
  /// and by the end it will be equal to `_children.length - 1`. This variable
  /// is always a valid index within the `_children` list.
  int _currentIndex;

  @override
  bool get completed {
    return _currentIndex == children.length - 1 &&
        children[_currentIndex].completed;
  }

  @override
  double? get duration {
    var totalDuration = 0.0;
    for (final controller in children) {
      final d = controller.duration;
      if (d == null) {
        return null;
      }
      totalDuration += d;
    }
    return totalDuration;
  }

  @override
  bool get isRandom => children.any((c) => c.isRandom);

  @override
  double get progress => children[_currentIndex].progress;

  @override
  double advance(double dt) {
    var t = children[_currentIndex].advance(dt);
    while (t > 0 && _currentIndex < children.length - 1) {
      _currentIndex++;
      t = children[_currentIndex].advance(t);
    }
    return t;
  }

  @override
  double recede(double dt) {
    var t = children[_currentIndex].recede(dt);
    while (t > 0 && _currentIndex > 0) {
      _currentIndex--;
      t = children[_currentIndex].recede(t);
    }
    return t;
  }

  @override
  void setToStart() {
    _currentIndex = 0;
    children.forEach((c) => c.setToStart());
  }

  @override
  void setToEnd() {
    _currentIndex = children.length - 1;
    children.forEach((c) => c.setToEnd());
  }

  @override
  void onMount(Effect parent) => children.forEach((c) => c.onMount(parent));
}
