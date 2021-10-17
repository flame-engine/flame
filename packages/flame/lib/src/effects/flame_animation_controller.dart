
typedef VoidCallback = void Function();

/// Helper class to facilitate animation of Effects.
///
/// Unlike the classical AnimationController, this class does not use a Ticker
/// to keep track of time. Instead, it must be pushed through time manually, by
/// calling the `update()` method within the game loop.
///
/// The main job of this class is to provide the variable [progress], which
/// is in the range from 0.0 to 1.0, updating this variable over time. The value
/// of 0.0 corresponds to the beginning of the animation, and the value of 1.0
/// is the end of the animation.
abstract class FlameAnimationController {
  /// The callback which is called when the effect is about to start.
  // VoidCallback? onStart;

  /// The callback which is called when the effect is completed.
  // VoidCallback? onComplete;

  /// Will the effect continue to run forever?
  bool get isInfinite;

  /// Has the effect started running?
  bool get started;

  /// Has the effect already completed running?
  bool get completed;

  /// The current value of the animation.
  ///
  /// This variable changes from 0 to 1 over time, which can be used by an
  /// animation to produce the desired transition effect. In essence, you can
  /// think of this variable as a "logical time".
  double get progress;

  /// Reverts the controller to its initial state, as it was before the start
  /// of the animation.
  void reset();

  /// Advances this animation controller's internal clock by [dt] seconds.
  ///
  /// Normally, this method will be called by the owner of the controller class.
  /// For example, if the controller is passed to an EffectComponent class,
  /// then that class will take care of calling the `update()` method as
  /// necessary.
  void update(double dt);
}
