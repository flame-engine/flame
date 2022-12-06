import 'package:flame/components.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:meta/meta.dart';

/// An [Effect] is a component that changes properties or appearance of another
/// component over time.
///
/// For example, suppose you have an object "Goo", and you want to move it
/// to some other point on the screen. Directly changing that object's position
/// will cause it to teleport to the new location, which is likely undesired.
/// A second approach that you can take is to modify Goo's `update()` method
/// to implement the logic that will move Goo to the new position smoothly.
/// However, implementing such logic for every component that you may need to
/// move is cumbersome. A better approach then is to implement that logic as a
/// separate "movement" component that can attach to Foo or to any other
/// suitable object and cause them to move to the desired location. Such a
/// separate component responsible for changing other components is an Effect.
///
/// Every [Effect] has a [controller], which describes how this effect evolves
/// over time. The effect also expects to be mounted into the game tree as a
/// regular component, in order to be able to use its controller.
///
/// This class describes an abstract effect. Concrete implementations are
/// expected to define the `apply()` method, which facilitates the necessary
/// changes in the effect's target; and also the `reset()` method if they have
/// non-trivial internal state.
abstract class Effect extends Component {
  Effect(this.controller, {this.onComplete})
      : removeOnFinish = true,
        _paused = false,
        _started = false,
        _finished = false {
    controller.onMount(this);
  }

  /// An object that describes how the effect should evolve over time.
  final EffectController controller;

  /// Whether the effect should be removed from its parent once it is completed,
  /// true by default.
  ///
  /// Setting this to false will cause the effect component to remain in the
  /// game tree in the "completed" state. However, you can `reset()` the effect
  /// in order to make it run once again.
  bool removeOnFinish;

  /// Optional callback function to be invoked once the effect completes.
  void Function()? onComplete;

  /// Boolean indicators of the effect's state, their purpose is to ensure that
  /// the `onStart()` and `onFinish()` callbacks are called exactly once.
  bool _started;
  bool _finished;

  /// The effect's `progress` variable as it was the last time that the
  /// `apply()` method was called. Mostly used by the derived classes.
  double get previousProgress => _lastProgress;
  double _lastProgress = 0;

  /// Whether the effect is paused or not.
  ///
  /// By default, the effect will not be paused, even when it is in the
  /// "completed" state. Use methods `pause()` and `resume()` in order to
  /// control this property. When the effect is paused, it is as if the time
  /// stops for it.
  bool get isPaused => _paused;
  bool _paused;

  /// Pause the effect. The effect will not respond to updates while it is
  /// paused. Calling `resume()` or `reset()` will un-pause it. Pausing an
  /// already paused effect is a no-op.
  void pause() => _paused = true;

  /// Resume updates in a previously paused effect. If the effect is not
  /// currently paused, this call is a no-op.
  void resume() => _paused = false;

  /// Restore the effect to its original state as it was when the effect was
  /// just created.
  ///
  /// A common use case for this method is to have an effect which is
  /// permanently attached to its target (i.e. with `removeOnFinish == false`),
  /// and then periodically resetting this effect each time you need to apply
  /// it to the target.
  @mustCallSuper
  void reset() {
    controller.setToStart();
    _paused = false;
    _started = false;
    _finished = false;
    _lastProgress = 0;
  }

  @mustCallSuper
  void resetToEnd() {
    controller.setToEnd();
    _started = true;
    _finished = true;
    _lastProgress = 1;
  }

  /// Implementation of [Component]'s `update()` method. Derived classes are
  /// not expected to redefine this.
  @override
  void update(double dt) {
    if (_paused || _finished) {
      return;
    }
    if (!_started && controller.started) {
      _started = true;
      onStart();
    }
    controller.advance(dt);
    if (_started) {
      final progress = controller.progress;
      apply(progress);
      _lastProgress = progress;
    }
    if (!_finished && controller.completed) {
      _finished = true;
      onFinish();
      if (removeOnFinish) {
        removeFromParent();
      }
    }
  }

  /// Used for SequenceEffect. This is similar to `update()`, but cannot be
  /// paused, does not obey [removeOnFinish], and returns the "leftover time"
  /// similar to `EffectController.advance`.
  @internal
  double advance(double dt) {
    if (!_started && controller.started) {
      _started = true;
      onStart();
    }
    final remainingDt = controller.advance(dt);
    if (_started) {
      final progress = controller.progress;
      apply(progress);
      _lastProgress = progress;
    }
    if (!_finished && controller.completed) {
      _finished = true;
      onFinish();
    }
    return remainingDt;
  }

  /// Used for SequenceEffect. This is similar to `update()`, but the effect is
  /// moved back in time. The callbacks onStart/onFinish will not be called.
  /// This method returns the "leftover time" similar to
  /// `EffectController.recede`.
  @internal
  double recede(double dt) {
    if (_finished && dt > 0) {
      _finished = false;
    }
    final remainingDt = controller.recede(dt);
    if (_started) {
      final progress = controller.progress;
      apply(progress);
      _lastProgress = progress;
    }
    return remainingDt;
  }

  //#region API to be implemented by the derived classes

  /// This method is called once when the effect is about to start, but before
  /// the first call to `apply()`. The notion of "about to start" is defined by
  /// the [controller]: this method is called when `controller.started` property
  /// first becomes true.
  ///
  /// If the effect is reset, its `onStart()` method will be called again when
  /// the effect is about to start.
  void onStart() {}

  /// This method is called once when the effect is about to finish, but before
  /// it is removed from its parent. The notion of "about to finish" is defined
  /// by the [controller]: this method is called when `controller.completed`
  /// property first becomes true.
  ///
  /// If the effect is reset, its [onFinish] method will be called again after
  /// the effect has finished again.
  @mustCallSuper
  void onFinish() {
    onComplete?.call();
  }

  /// Apply the given [progress] level to the effect's target.
  ///
  /// Here [progress] is a variable that is typically in the range from 0 to 1,
  /// with 0 being the initial state, and 1 the final state of the effect. See
  /// [EffectController] for details.
  ///
  /// This is a main method that MUST be implemented in every derived class.
  void apply(double progress);

  //#endregion
}
