import 'controllers/linear_effect_controller.dart';
import 'effect.dart';

/// Run multiple [effects] in a sequence, one after another.
///
/// The provided effects will be added as child components; however the custom
/// `updateTree()` implementation ensures that only one of them is "active" at
/// a time.
///
/// If the [alternate] flag is provided, then the sequence will run in the
/// reverse after it ran forward.
///
class SequenceEffect extends Effect {
  SequenceEffect(
    this.effects, {
    this.alternate = false,
  })  : assert(effects.isNotEmpty, 'The list of effects cannot be empty'),
        super(LinearEffectController(1)) {
    addAll(effects);
  }

  final List<Effect> effects;

  /// If this flag is true, then after the sequence runs to the end, it will
  /// then run in again in the reverse order.
  final bool alternate;

  /// Index of the currently running effect within the [effects] list. If there
  /// are n effects in total, then this runs as 0, 1, ..., n-1. After that, if
  /// the effect alternates, then the `_index` continues as -1, -2, ..., -n,
  /// where -1 is the last effect and -n is the first.
  int _index = 0;

  @override
  void apply(double progress) {}

  @override
  void updateTree(double dt, {bool callOwnUpdate = true}) {
    if (isPaused) {
      return;
    }
    final currentEffect = effects[_index + (_index < 0 ? effects.length : 0)];
    currentEffect.updateTree(dt);
    if (currentEffect.controller.completed) {
      _index++;
    }
  }

  @override
  double runForward(double dt) {
    final n = effects.length;
    var timeLeft = dt;
    while (timeLeft > 0) {
      var i = _index % n; // turns negative indices into positive
      // "Forward" arm of a regular or an alternating effect
      if (_index >= 0) {
        timeLeft = effects[i].runForward(timeLeft);
        if (timeLeft == 0) {
          break;
        }
        i += 1;
      }
      // "Backward" arm of an alternating effect
      else {
        timeLeft = effects[i].runBackward(timeLeft);
        if (timeLeft < 0) {
          i -= 1;
        }
      }
    }
    return timeLeft;
  }

  double _goForwardOnForwardRun(double dt) {
    assert(_index >= 0);
    final remainingTime = effects[_index].runForward(dt);
    if (remainingTime > 0) {
      _index += 1;
      // Reached the end of the run
      if (_index == effects.length) {
        if (alternate) {
          _index = -1;
        }
      }
    }
    return remainingTime;
  }
}
