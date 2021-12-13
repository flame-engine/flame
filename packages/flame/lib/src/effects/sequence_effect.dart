import 'package:flame/effects.dart';

import 'controllers/effect_controller.dart';
import 'effect.dart';

/// Run multiple effects in a sequence, one after another.
///
/// The provided effects will be added as child components; however the custom
/// `updateTree()` implementation ensures that only one of them is "active" at
/// a time.
///
/// If the `alternate` flag is provided, then the sequence will run in the
/// reverse after it ran forward.
///
class SequenceEffect extends Effect {
  SequenceEffect(
    List<Effect> effects, {
    bool alternate = false,
    bool infinite = false,
    int repeatCount = 1,
  })  : assert(effects.isNotEmpty, 'The list of effects cannot be empty'),
        super(_buildController(effects, alternate, infinite, repeatCount)) {
    addAll(effects);
  }

  static EffectController _buildController(
    List<Effect> effects,
    bool alternate,
    bool infinite,
    int repeatCount,
  ) {
    final ec = _SequenceEffectEffectController(effects, alternate);
    if (infinite) {
      return InfiniteEffectController(ec);
    } else if (repeatCount > 1) {
      return RepeatedEffectController(ec, repeatCount);
    }
    return ec;
  }

  @override
  void apply(double progress) {}



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

/// Not to be confused with `SequenceEffectController`!
///
///
class _SequenceEffectEffectController extends EffectController {
  _SequenceEffectEffectController(
    this.effects,
    this.alternate,
  ) : super.empty();

  final List<Effect> effects;

  /// If this flag is true, then after the sequence runs to the end, it will
  /// run again in the reverse order.
  final bool alternate;

  /// Index of the currently running effect within the [effects] list. If there
  /// are n effects in total, then this runs as 0, 1, ..., n-1. After that, if
  /// the effect alternates, then the `_index` continues as -1, -2, ..., -n,
  /// where -1 is the last effect and -n is the first.
  int _index = 0;

  @override
  bool get completed => throw UnimplementedError();

  @override
  double advance(double dt) {
    // TODO: implement advance
    throw UnimplementedError();
  }

  @override
  // TODO: implement duration
  double? get duration => throw UnimplementedError();

  @override
  // TODO: implement progress
  double get progress => throw UnimplementedError();

  @override
  double recede(double dt) {
    // TODO: implement recede
    throw UnimplementedError();
  }

  @override
  void setToEnd() {
    // TODO: implement setToEnd
  }

  @override
  void setToStart() {
    // TODO: implement setToStart
  }
}
