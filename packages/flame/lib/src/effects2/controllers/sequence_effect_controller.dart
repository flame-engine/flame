import 'effect_controller.dart';

/// An effect controller that executes a list of other controllers one after
/// another.
class SequenceEffectController extends EffectController {
  SequenceEffectController(List<EffectController> controllers)
    : assert(controllers.isNotEmpty, 'List of controllers cannot be empty'),
      assert(!controllers.any((c) => c.isInfinite),
        'Children controllers cannot be infinite',
      ),
      _children = controllers,
      _currentIndex = 0;

  final List<EffectController> _children;

  /// The index of the controller currently being executed. This starts with 0,
  /// and by the end it will be equal to `_children.length - 1`. This variable
  /// is always a valid index within the `_children` list.
  int _currentIndex;

  @override
  bool get completed {
    return _currentIndex == _children.length - 1 &&
        _children[_currentIndex].completed;
  }

  @override
  double? get duration {
    var totalDuration = 0.0;
    for (final controller in _children) {
      final d = controller.duration;
      if (d == null) {
        return null;
      }
      totalDuration += d;
    }
    return totalDuration;
  }

  @override
  bool get isRandom => _children.any((c) => c.isRandom);

  @override
  double get progress => _children[_currentIndex].progress;

  @override
  double advance(double dt) {
    var t = _children[_currentIndex].advance(dt);
    while (t > 0 && _currentIndex < _children.length - 1) {
      _currentIndex++;
      t = _children[_currentIndex].advance(t);
    }
    return t;
  }

  @override
  double recede(double dt) {
    var t = _children[_currentIndex].recede(dt);
    while (t > 0 && _currentIndex > 0) {
      _currentIndex--;
      t = _children[_currentIndex].recede(t);
    }
    return t;
  }

  @override
  void reset() {
    super.reset();
    _currentIndex = 0;
    _children.map((c) => c.reset());
  }

  @override
  void setToEnd() {
    _currentIndex = _children.length - 1;
    _children.map((c) => c.setToEnd());
  }
}
