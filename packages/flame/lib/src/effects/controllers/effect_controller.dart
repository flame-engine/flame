import 'package:flutter/animation.dart';

import 'curved_effect_controller.dart';
import 'delayed_effect_controller.dart';
import 'infinite_effect_controller.dart';
import 'linear_effect_controller.dart';
import 'pause_effect_controller.dart';
import 'repeated_effect_controller.dart';
import 'reverse_curved_effect_controller.dart';
import 'reverse_linear_effect_controller.dart';
import 'sequence_effect_controller.dart';

/// Base "controller" class to facilitate animation of effects.
///
/// The purpose of an effect controller is to define how an effect or an
/// animation should progress over time. To facilitate that, this class provides
/// variable [progress], which will grow from 0.0 to 1.0. The value of 0
/// corresponds to the beginning of an animation, and the value of 1.0 is
/// the end of the animation.
///
/// The [progress] variable can best be thought of as a "logical time". For
/// example, if you want to animate a certain property from value A to value B,
/// then you can use [progress] to linearly interpolate between these two
/// extremes and obtain variable `x = A*(1 - progress) + B*progress`.
///
/// The exact behavior of [progress] is determined by subclasses, but the
/// following general considerations apply:
///   - the progress can also go in negative direction (i.e. from 1 to 0);
///   - the progress may oscillate, going from 0 to 1, then back to 0, etc;
///   - the progress may change over a finite or infinite period of time;
///   - the value of 0 corresponds to the logical start of an animation;
///   - the value of 1 is either the end or the "peak" of an animation;
///   - the progress may briefly attain values outside of [0; 1] range (for
///     example if a "bouncy" easing curve is applied).
///
/// An [EffectController] can be made to run forward in time (`advance()`), or
/// backward in time (`recede()`).
///
/// Unlike the `dart.ui.AnimationController`, this class does not use a `Ticker`
/// to keep track of time. Instead, it must be pushed through time manually, by
/// calling the `update()` method within the game loop.
abstract class EffectController {
  /// Factory function for producing common [EffectController]s.
  ///
  /// In the simplest case, when only `duration` is provided, this will return
  /// a [LinearEffectController] that grows linearly from 0 to 1 over the period
  /// of that duration.
  ///
  /// More generally, the produced effect controller allows to add a delay
  /// before the beginning of the animation, to animate both forward and in
  /// reverse, to iterate several times (or infinitely), to apply an arbitrary
  /// [curve] making the effect progression non-linear, etc.
  ///
  /// In the most general case, the animation proceeds through the following
  /// steps:
  ///   1. wait for [startDelay] seconds,
  ///   2. repeat the following steps [repeatCount] times (or [infinite]ly):
  ///       a. progress from 0 to 1 over the [duration] seconds,
  ///       b. wait for [atMaxDuration] seconds,
  ///       c. progress from 1 to 0 over the [reverseDuration] seconds,
  ///       d. wait for [atMinDuration] seconds.
  ///
  /// Setting parameter [alternate] to true is another way to create a
  /// controller whose [reverseDuration] is the same as the forward [duration].
  ///
  /// If the animation is finite and there are no "backward" or "atMin" stages
  /// then the animation will complete at `progress == 1`, otherwise it will
  /// complete at `progress == 0`.
  factory EffectController({
    required double duration,
    Curve curve = Curves.linear,
    double? reverseDuration,
    Curve? reverseCurve,
    bool infinite = false,
    bool alternate = false,
    int? repeatCount,
    double startDelay = 0.0,
    double atMaxDuration = 0.0,
    double atMinDuration = 0.0,
  }) {
    final isLinear = curve == Curves.linear;
    final hasReverse = alternate || (reverseDuration != null);
    final reverseIsLinear =
        reverseCurve == Curves.linear || ((reverseCurve == null) && isLinear);
    final items = [
      if (isLinear) LinearEffectController(duration),
      if (!isLinear) CurvedEffectController(duration, curve),
      if (atMaxDuration != 0) PauseEffectController(atMaxDuration, progress: 1),
      if (hasReverse && reverseIsLinear)
        ReverseLinearEffectController(reverseDuration ?? duration),
      if (hasReverse && !reverseIsLinear)
        ReverseCurvedEffectController(
          reverseDuration ?? duration,
          reverseCurve ?? curve.flipped,
        ),
      if (atMinDuration != 0) PauseEffectController(atMinDuration, progress: 0),
    ];
    assert(items.isNotEmpty);
    var controller =
        items.length == 1 ? items[0] : SequenceEffectController(items);
    if (infinite) {
      assert(
        repeatCount == null,
        'An infinite animation cannot have a repeat count',
      );
      controller = InfiniteEffectController(controller);
    }
    if (repeatCount != null && repeatCount != 1) {
      assert(repeatCount > 0, 'repeatCount must be positive');
      controller = RepeatedEffectController(controller, repeatCount);
    }
    if (startDelay != 0) {
      controller = DelayedEffectController(controller, delay: startDelay);
    }
    return controller;
  }

  EffectController.empty();

  /// Will the effect continue to run forever (never completes)?
  bool get isInfinite => false;

  /// Is the effect's duration random or fixed?
  bool get isRandom => false;

  /// Total duration of the effect. If the duration cannot be determined, this
  /// will return `null`.
  double? get duration;

  /// Has the effect started running? Some effects use a "delay" parameter to
  /// postpone the start of an animation. This property then tells you whether
  /// this delay period has already passed.
  bool get started => true;

  /// Has the effect already finished?
  ///
  /// For a finite animation, this property will turn `true` once the animation
  /// has finished running and the [progress] variable will no longer change
  /// in the future. For an infinite animation this should always return
  /// `false`.
  bool get completed;

  /// The current progress of the effect, a value between 0 and 1.
  double get progress;

  /// Advances this controller's internal clock by [dt] seconds.
  ///
  /// If the controller is still running, the return value will be 0. If it
  /// already finished, then the return value will be the "leftover" part of
  /// the [dt]. That is, the amount of time [dt] that remains after the
  /// controller has finished.
  ///
  /// Normally, this method will be called by the owner of the controller class.
  /// For example, if the controller is passed to an `Effect` class, then that
  /// class will take care of calling this method as necessary.
  double advance(double dt);

  /// Similar to `advance()`, but makes the effect controller move back in time.
  ///
  /// If the supplied amount of time [dt] would push the effect past its
  /// starting point, then the effect stops at the start and the "leftover"
  /// portion of [dt] is returned.
  double recede(double dt);

  /// Reverts the controller to its initial state, as it was before the start
  /// of the animation.
  void setToStart();

  /// Puts the controller into its final "completed" state.
  void setToEnd();
}
