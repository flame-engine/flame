import 'package:flutter/animation.dart';

import 'effect_controller.dart';

/// A commonly used implementation of a [EffectController].
///
/// In the simplest case, [StandardEffectController] will have a positive
/// `duration` and will change its [progress] linearly from 0 to 1 over the
/// period of that duration.
///
/// More generally, a [StandardEffectController] allows to add a delay before
/// the beginning of the animation, to animate both forward and in reverse,
/// to iterate several times (or infinitely), to apply an arbitrary [Curve]
/// making the effect progression non-linear, etc.
///
/// In the most general case, the animation proceeds through the following
/// steps:
///   1. wait for [startDelay] seconds,
///   2. repeat the following steps [repeatCount] times (or infinitely):
///       a. progress from 0 to 1 over the [forwardDuration] seconds,
///       b. wait for [atMaxDuration] seconds,
///       c. progress from 1 to 0 over the [backwardDuration] seconds,
///       d. wait for [atMinDuration] seconds,
///   3. mark the animation as [completed].
///
/// If the animation is finite and there are no `backward` or `atMin` stages
/// then the animation will complete at `progress == 1`, otherwise it will
/// complete at `progress == 0`.
///
/// The animation is "sticky" at the end of the `forward` and `backward` stages.
/// This means that within a single [update()] call the animation may complete
/// these stages but will not move on to the next ones. Thus, you're guaranteed
/// to be able to observe `progress == 1` and `progress == 0` at least once
/// within each iteration cycle.
class StandardEffectController extends EffectController {
  StandardEffectController({
    required double duration,
    Curve curve = Curves.linear,
    double reverseDuration = 0.0,
    Curve? reverseCurve,
    bool infinite = false,
    int? repeatCount,
    this.startDelay = 0.0,
    this.atMaxDuration = 0.0,
    this.atMinDuration = 0.0,
  })  : assert(
          infinite ? repeatCount == null : true,
          'An infinite animation cannot have a repeat count',
        ),
        assert(
          !infinite ? (repeatCount ?? 1) > 0 : true,
          'repeatCount must be positive',
        ),
        assert(duration > 0, 'duration must be positive'),
        assert(reverseDuration >= 0, 'reverseDuration cannot be negative'),
        assert(startDelay >= 0, 'startDelay cannot be negative'),
        assert(atMaxDuration >= 0, 'atMaxDuration cannot be negative'),
        assert(atMinDuration >= 0, 'atMinDuration cannot be negative'),
        repeatCount = infinite ? -1 : (repeatCount ?? 1),
        forwardDuration = duration,
        backwardDuration = reverseDuration,
        forwardCurve = curve,
        backwardCurve =
            reverseCurve ?? (curve == Curves.linear ? curve : curve.flipped),
        _progress = 0,
        _remainingIterationsCount = repeatCount ?? (infinite ? -1 : 1),
        _remainingTimeAtCurrentStage = startDelay,
        _stage = _AnimationStage.beforeStart;

  /// The current value of the animation.
  ///
  /// This variable changes from 0 to 1 over time, which can be used by an
  /// animation to produce the desired transition effect. In essence, you can
  /// think of this variable as a "logical time".
  ///
  /// This variable is guaranteed to be 0 during the `beforeStart` and `atMin`
  /// periods, and to be 1 during the `atMax` period. During the `forward`
  /// period this variable changes from 0 to 1, and during the `backward` period
  /// it goes back from 1 to 0. However, during the latter two periods it is
  /// possible for `progress` to become less than 0 or greater than 1 if either
  /// the [forwardCurve] or the [backwardCurve] produce values outside of [0; 1]
  /// range.
  @override
  double get progress => _progress;
  double _progress;

  /// The transformation curve that applies during the `forward` stage. By
  /// default, the curve is linear.
  ///
  /// The effect of the curve is that if the animation is normally at x% of its
  /// progression during the `forward` stage, then the reported [progress] will
  /// be equal to `forwardCurve.progress(x)`.
  final Curve forwardCurve;

  /// The transformation curve that applies during the `backward` stage. By
  /// default, the curve is the flipped to [forwardCurve].
  ///
  /// The effect of the curve is that if the animation is at normally x% of its
  /// progression during the `backward` stage, then the reported [progress] will
  /// be equal to `backwardCurve.progress(x)`.
  final Curve backwardCurve;

  /// The number of times to play the animation, defaults to 1.
  ///
  /// If this value is negative, it indicates an infinitely repeating animation.
  /// This value cannot be zero.
  final int repeatCount;

  /// Will the effect continue to loop forever?
  @override
  bool get isInfinite => repeatCount < 0;

  int _remainingIterationsCount;

  @override
  bool get started => _stage != _AnimationStage.beforeStart;

  @override
  bool get completed => _remainingIterationsCount == 0;

  /// The time (in seconds) before the animation begins. During this time
  /// the property [started] will be returning false, and [progress] will be 0.
  final double startDelay;

  final double forwardDuration;
  final double backwardDuration;
  final double atMaxDuration;
  final double atMinDuration;

  double get cycleDuration {
    return forwardDuration + atMaxDuration + backwardDuration + atMinDuration;
  }

  bool get isSimpleAnimation =>
      atMaxDuration + backwardDuration + atMinDuration == 0;

  _AnimationStage _stage;
  double _remainingTimeAtCurrentStage;

  @override
  void update(double dt) {
    if (completed) {
      return;
    }
    _remainingTimeAtCurrentStage -= dt;
    // When remaining time becomes zero or negative, it means we're
    // transitioning into the next stage.
    //
    // In each iteration of the while loop below we transition to the next
    // stage and add the next stage's duration to the remaining timer. This may
    // not be enough to make the timer positive (particularly if some stage has
    // duration 0), which means we need to keep progressing onto the next stage.
    //
    // The exceptions to this rule are the "forward" and "backward" stages which
    // always exit at the end, even if the timer is negative. This allows us to
    // have "sticky" start and end of an animation, i.e. the controller will
    // never jump over points with progress=0 or progress=1.
    while (_remainingTimeAtCurrentStage <= 0) {
      // In the switch below we are *finishing* each of the indicated stages.
      switch (_stage) {
        case _AnimationStage.beforeStart:
          _remainingTimeAtCurrentStage += forwardDuration;
          _stage = _AnimationStage.forward;
          break;
        case _AnimationStage.forward:
          _progress = 1;
          _remainingTimeAtCurrentStage += atMaxDuration;
          _stage = _AnimationStage.atMax;
          if (_remainingIterationsCount == 1 && isSimpleAnimation) {
            _markCompleted();
          }
          return;
        case _AnimationStage.atMax:
          _remainingTimeAtCurrentStage += backwardDuration;
          _stage = _AnimationStage.backward;
          if (_remainingIterationsCount == 1 &&
              backwardDuration == 0 &&
              atMinDuration == 0) {
            _markCompleted();
            return;
          }
          break;
        case _AnimationStage.backward:
          _progress = 0;
          _remainingTimeAtCurrentStage += atMinDuration;
          _stage = _AnimationStage.atMin;
          return;
        case _AnimationStage.atMin:
          _remainingTimeAtCurrentStage += forwardDuration;
          _stage = _AnimationStage.forward;
          if (!isInfinite) {
            _remainingIterationsCount -= 1;
            if (_remainingIterationsCount == 0) {
              _markCompleted();
              return;
            }
          }
          break;
      }
    }
    assert(_remainingTimeAtCurrentStage > 0);
    if (_stage == _AnimationStage.forward) {
      _progress = forwardCurve.transform(
        1 - _remainingTimeAtCurrentStage / forwardDuration,
      );
    }
    if (_stage == _AnimationStage.backward) {
      _progress = backwardCurve.transform(
        _remainingTimeAtCurrentStage / backwardDuration,
      );
    }
  }

  @override
  void reset() {
    _progress = 0;
    _stage = _AnimationStage.beforeStart;
    _remainingTimeAtCurrentStage = startDelay;
    _remainingIterationsCount = repeatCount;
  }

  void _markCompleted() {
    _remainingTimeAtCurrentStage = double.infinity;
    _remainingIterationsCount = 0;
  }
}

enum _AnimationStage {
  beforeStart,
  forward,
  atMax,
  backward,
  atMin,
}
