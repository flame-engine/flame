/// Base "controller" class to facilitate animation of effects.
///
/// The purpose of an effect controller is to define how an effect or an
/// animation should progress over time. To facilitate that, this class provides
/// variable [progress], which will grow from 0.0 to 1.0 over time. The value
/// of 0 corresponds to the beginning of an animation, and the value of 1.0 is
/// the end of the animation.
///
/// The [progress] variable can be best thought of as a "logical time". For
/// example, if you want to animate a certain property from value A to value B,
/// then you can use [progress] to linearly interpolate between these two
/// extremes and obtain variable `x = A*(1 - progress) + B*progress`.
///
/// The exact behavior of [progress] is determined by subclasses, but the
/// following general considerations apply:
///   - the progress may go in negative direction (i.e. from 1 to 0);
///   - the progress may oscillate, going from 0 to 1, then back to 0, etc;
///   - the progress may change over a finite or infinite period of time;
///   - the value of 0 corresponds to logical start of an animation;
///   - the value of 1 is either a start or "peak" of an animation;
///   - the progress may briefly attain values outside of [0; 1] range (for
///     example if a "bouncy" easing curve is applied).
///
/// Unlike the `dart.ui.AnimationController`, this class does not use a `Ticker`
/// to keep track of time. Instead, it must be pushed through time manually, by
/// calling the `update()` method within the game loop.
abstract class EffectController {
  /// Will the effect continue to run forever (i.e. has no logical end)?
  bool get isInfinite;

  /// Has the effect started running? Some effects use a "delay" parameter to
  /// postpone the start of an animation. This property then tells you whether
  /// this delay period has already passed.
  bool get started;

  /// Has the effect already completed running?
  ///
  /// For a finite animation, this property will turn `true` once the animation
  /// has finished running and the [progress] variable will no longer change
  /// in the future. For an infinite animation this should always return
  /// `false`.
  bool get completed;

  /// The current value of the effect/animation, a value between 0 and 1.
  double get progress;

  /// Reverts the controller to its initial state, as it was before the start
  /// of the animation.
  void reset();

  /// Advances this controller's internal clock by [dt] seconds.
  ///
  /// Normally, this method will be called by the owner of the controller class.
  /// For example, if the controller is passed to an `Effect` class, then that
  /// class will take care of calling the `update()` method as necessary.
  void update(double dt);
}
