import 'package:meta/meta.dart';

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
/// In addition to its normal behavior, an [EffectController] can also be made
/// to run backward in time using the `reverse()` method. The property
/// [isRunningForward] indicates whether the controller was reversed or not.
///
///
/// Unlike the `dart.ui.AnimationController`, this class does not use a `Ticker`
/// to keep track of time. Instead, it must be pushed through time manually, by
/// calling the `update()` method within the game loop.
abstract class EffectController {
  /// Is the effect currently running in the "forward" direction?
  bool get isRunningForward => _forward;
  bool _forward = true;

  /// Will the effect continue to run forever (never completes)?
  bool get isInfinite => false;

  /// Is the effect's duration random or fixed?
  bool get isRandom => false;

  /// Total duration of the effect. If the effect is either infinite or random,
  /// this will return `null`.
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

  /// Advances this controller's internal clock by [dt] seconds. This method
  /// will be called when the effect controller is [isRunningForward].
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

  /// Similar to `advance()`, but invoked when the controller is going backwards
  /// in time. Thus, this method is called when `goingForward == false`.
  double recede(double dt);

  /// Reverts the controller to its initial state, as it was before the start
  /// of the animation.
  void setToStart();

  /// Puts the controller into its final "completed" state.
  void setToEnd();

  /// Force the controller to run backwards in time.
  ///
  /// The exact interpretation of this is left up to each controller, but the
  /// general idea is that the controller should appear as if it was recorded
  /// on video and then that video was played backwards.
  @nonVirtual
  void reverse() {
    _forward = !_forward;
  }

  /// Tell the controller that [dt] seconds has passed in-game.
  ///
  /// This method is for use by the `Effect` class only, and will ignore any
  /// "leftover" parts of the timer.
  @nonVirtual
  void update(double dt) {
    if (_forward) {
      advance(dt);
    } else {
      recede(dt);
    }
  }
}


