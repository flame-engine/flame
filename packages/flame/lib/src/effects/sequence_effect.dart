import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/controllers/infinite_effect_controller.dart';
import 'package:flame/src/effects/controllers/repeated_effect_controller.dart';
import 'package:flame/src/effects/effect.dart';

/// Run multiple effects in a sequence, one after another.
///
/// The provided effects will be added as child components; however the custom
/// `updateTree()` implementation ensures that only one of them runs at any
/// point in time. The flags `paused` or `removeOnFinish` will be ignored for
/// children effects.
///
/// If the `alternate` flag is provided, then the sequence will run in the
/// reverse after it ran forward.
///
/// Parameter `repeatCount` will make the sequence repeat a certain number of
/// times. If `alternate` is also true, then the sequence will first run
/// forward, then back, and then repeat this pattern `repeatCount` times in
/// total.
///
/// The flag `infinite = true` makes the sequence repeat infinitely. This is
/// equivalent to setting `repeatCount = infinity`. If both the `infinite` and
/// the `repeatCount` parameters are given, then `infinite` takes precedence.
///
/// Note that unlike other effects, [SequenceEffect] does not take an
/// [EffectController] as a parameter. This is because the timing of a sequence
/// effect depends on the timings of individual effects, and cannot be
/// represented as a regular effect controller.
class SequenceEffect extends Effect {
  factory SequenceEffect(
    List<Effect> effects, {
    bool alternate = false,
    bool infinite = false,
    int repeatCount = 1,
  }) {
    assert(effects.isNotEmpty, 'The list of effects cannot be empty');
    assert(
      !(infinite && repeatCount != 1),
      'Parameters infinite and repeatCount cannot be specified simultaneously',
    );
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
  void updateTree(double dt) {
    update(dt);
    // Do not update children: the controller will take care of it
  }
}

/// Helper class that implements the functionality of a [SequenceEffect]. This
/// class should not be confused with `SequenceEffectController` (which runs
/// a sequence of effect controllers).
///
/// This effect controller does not strictly adheres to the interface of a
/// proper [EffectController]: in particular, its [progress] is ill-defined.
/// The provided implementation returns a value proportional to the number of
/// effects that has already completed, however this is not used anywhere since
/// `SequenceEffect.apply()` is empty.
class _SequenceEffectEffectController extends EffectController {
  _SequenceEffectEffectController(
    this.effects,
    this.alternate,
  ) : super.empty();

  /// The list of children effects.
  final List<Effect> effects;

  /// If this flag is true, then after the sequence runs to the end, it will
  /// run again in the reverse order.
  final bool alternate;

  /// Index of the currently running effect within the [effects] list. If there
  /// are n effects in total, then this runs as 0, 1, ..., n-1. After that, if
  /// the effect alternates, then the `_index` continues as -1, -2, ..., -n,
  /// where -1 is the last effect and -n is the first.
  int _index = 0;

  /// The effect that is currently being executed.
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
  bool get isRandom {
    return effects.any((e) => e.controller.isRandom);
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
      if (t == 0) {
        break;
      }
    }
    return t;
  }

  @override
  void setToEnd() {
    if (alternate) {
      _index = -n;
      effects.forEach((e) => e.reset());
    } else {
      _index = n - 1;
      effects.forEach((e) => e.resetToEnd());
    }
    _completed = true;
  }

  @override
  void setToStart() {
    _index = 0;
    _completed = false;
    effects.forEach((e) => e.reset());
  }
}
