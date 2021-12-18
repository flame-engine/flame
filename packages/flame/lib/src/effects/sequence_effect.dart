import 'controllers/effect_controller.dart';
import 'controllers/infinite_effect_controller.dart';
import 'controllers/repeated_effect_controller.dart';
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
  factory SequenceEffect(
    List<Effect> effects, {
    bool alternate = false,
    bool infinite = false,
    int repeatCount = 1,
  }) {
    assert(effects.isNotEmpty, 'The list of effects cannot be empty');
    EffectController ec = _SequenceEffectEffectController(effects, alternate);
    if (infinite) {
      ec = InfiniteEffectController(ec);
    } else if (repeatCount > 1) {
      ec = RepeatedEffectController(ec, repeatCount);
    }
    effects.forEach((e) => e.removeOnFinish = false);
    return SequenceEffect._(ec)..addAll(effects);
  }

  SequenceEffect._(EffectController ec) : super(ec);

  @override
  void apply(double progress) {}

  @override
  void updateTree(double dt, {bool callOwnUpdate = true}) {
    update(dt);
    // Do not update children
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

  Effect get currentEffect => effects[_index < 0 ? _index + n : _index];

  /// Total number of effects in this sequence.
  int get n => effects.length;

  @override
  bool get completed => _completed;
  bool _completed = false;

  @override
  double? get duration {
    var totalDuration = 0.0;
    for (final effect in effects) {
      totalDuration += effect.controller.duration ?? 0;
    }
    if (alternate) {
      totalDuration *= 2;
    }
    return totalDuration;
  }

  @override
  double get progress => (_index + 1) / n;

  @override
  double advance(double dt) {
    var t = dt;
    for (;;) {
      if (_index >= 0) {
        t = currentEffect.advance(t);
        if (t > 0) {
          _index += 1;
          if (_index == n) {
            if (alternate) {
              _index = -1;
            } else {
              _index = n - 1;
              _completed = true;
              break;
            }
          }
        }
      } else {
        t = currentEffect.recede(t);
        if (t > 0) {
          _index -= 1;
          if (_index < -n) {
            _index = -n;
            _completed = true;
            break;
          }
        }
      }
      if (t == 0) {
        break;
      }
    }
    return t;
  }

  @override
  double recede(double dt) {
    if (_completed && dt > 0) {
      _completed = false;
    }
    var t = dt;
    for (;;) {
      if (_index >= 0) {
        t = currentEffect.recede(t);
        if (t > 0) {
          _index -= 1;
          if (_index < 0) {
            _index = 0;
            break;
          }
        }
      } else {
        t = currentEffect.advance(t);
        if (t > 0) {
          _index += 1;
          if (_index == 0) {
            _index = n - 1;
          }
        }
      }
    }
    return t;
  }

  @override
  void setToEnd() {
    if (alternate) {
      _index = -n;
      effects.forEach((e) => e.controller.setToStart());
    } else {
      _index = n - 1;
      effects.forEach((e) => e.controller.setToEnd());
    }
  }

  @override
  void setToStart() {
    _index = 0;
    effects.forEach((e) => e.reset());
  }
}
