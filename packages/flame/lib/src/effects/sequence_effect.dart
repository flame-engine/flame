import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/controllers/infinite_effect_controller.dart';
import 'package:flame/src/effects/controllers/repeated_effect_controller.dart';
import 'package:flame/src/effects/effect.dart';

EffectController _createController({
  required List<Effect> effects,
  required bool alternate,
  required AlternatePattern alternatePattern,
  required bool infinite,
  required int repeatCount,
}) {
  EffectController ec = _SequenceEffectEffectController(
    effects,
    alternate: alternate,
    alternatePattern: alternatePattern,
  );
  if (infinite) {
    ec = InfiniteEffectController(ec);
  } else if (repeatCount > 1) {
    ec = RepeatedEffectController(ec, repeatCount);
  }
  effects.forEach((e) => e.removeOnFinish = false);
  return ec;
}

/// Specifies how to playback an alternating [SequenceEffect] pattern.
///
/// [AlternatePattern.repeatLast] will replay the first and last [Effect]
/// when the sequence repeats, causing those [Effect]s to play twice-in-a-row.
///
/// [AlternatePattern.doNotRepeatLast] will not replay the first and last
/// [Effect] and instead jumps to the second and second-to-last [Effect]
/// respectively, if available, at the start of the alternating pattern.
/// This is equivalent to playing the first and last [Effect] once throughout
/// the combined span of the original pattern plus its reversed pattern.
enum AlternatePattern {
  repeatLast(1),
  doNotRepeatLast(2);

  final int value;
  const AlternatePattern(this.value);
}

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
/// Parameter `alternatePattern` is only used when `alternate` is true.
/// This parameter modifies how the pattern repeats in reverse.
/// See [AlternatePattern] for options.
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
  SequenceEffect(
    List<Effect> effects, {
    AlternatePattern alternatePattern = AlternatePattern.repeatLast,
    bool alternate = false,
    bool infinite = false,
    int repeatCount = 1,
    super.onComplete,
    super.key,
  })  : assert(effects.isNotEmpty, 'The list of effects cannot be empty'),
        assert(
          !(infinite && repeatCount != 1),
          'Parameters infinite and repeatCount cannot be specified '
          'simultaneously',
        ),
        super(
          _createController(
            effects: effects,
            alternate: alternate,
            alternatePattern: alternatePattern,
            infinite: infinite,
            repeatCount: repeatCount,
          ),
        ) {
    addAll(effects);
  }

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
    this.effects, {
    required this.alternate,
    required this.alternatePattern,
  }) : super.empty();

  /// The list of children effects.
  final List<Effect> effects;

  /// If this flag is true, then after the sequence runs to the end, it will
  /// run again in the reverse order.
  final bool alternate;

  /// If [alternate] is true, and after the sequence runs to completion once,
  /// this will run again in the reverse order according to the policy
  /// of the [AlternatePattern] value provided.
  final AlternatePattern alternatePattern;

  /// Index of the currently running effect within the [effects] list. If there
  /// are n effects in total, then this runs as 0, 1, ..., n-1. After that, if
  /// the effect alternates, then the `_index` continues as -1, -2, ..., -n,
  /// where -1 is the last effect and -n is the first.
  int _index = 0;

  /// The effect that is currently being executed.
  Effect get currentEffect => effects[_index < 0 ? _index + n : _index];

  /// Total number of effects in this sequence.
  int get n => effects.length;

  /// If [alternate] is not set, our last index will be `n-1`.
  /// Otherwise, the sequence approached 0 from the left of the
  /// numberline, and depending on if our [alternatePattern]
  /// includes or excludes the first [Effect], reduces the destination
  /// index by 1.
  int get _computeLastIndex => switch (alternate) {
        true => switch (alternatePattern) {
            AlternatePattern.repeatLast => -1,
            AlternatePattern.doNotRepeatLast => -2,
          },
        false => n - 1,
      };

  @override
  bool get completed => _completed;
  bool _completed = false;

  @override
  double? get duration {
    var totalDuration = 0.0;
    for (final effect in effects) {
      totalDuration += effect.controller.duration ?? 0;
    }

    // Abort early
    if (totalDuration == 0.0) {
      return totalDuration;
    }

    if (alternate) {
      totalDuration *= 2;

      if (alternatePattern == AlternatePattern.doNotRepeatLast) {
        totalDuration -= effects.first.controller.duration ?? 0;
        totalDuration -= effects.last.controller.duration ?? 0;
      }
    }

    return totalDuration;
  }

  @override
  bool get isRandom {
    return effects.any((e) => e.controller.isRandom);
  }

  @override
  double get progress => (_index < 0 ? -_index : _index + 1) / n;

  @override
  double advance(double dt) {
    var t = dt;
    for (;;) {
      if (_index >= 0) {
        t = currentEffect.advance(t);
        if (t > 0) {
          _index += 1;
          if (_index == n) {
            _index = _computeLastIndex;

            if (_index == n - 1) {
              _completed = true;
              break;
            }
          }
        }
      } else {
        // This case represents the reversed alternating pattern
        // when `alternate` is true. Our indices will be negative,
        // and we recede back to index 0.

        t = currentEffect.recede(t);
        if (t > 0) {
          _index -= 1;

          var lastIndex = -n;
          // Iff the requested alternate policy is `repeatLast`, then we must
          // include and play the start Effect before considering our sequence
          // completed.
          if (alternate && alternatePattern == AlternatePattern.repeatLast) {
            lastIndex -= 1;
          }

          if (_index == lastIndex) {
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
    _index = _computeLastIndex;

    if (_index == n - 1) {
      effects.forEach((e) => e.resetToEnd());
    } else {
      effects.forEach((e) => e.reset());
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
