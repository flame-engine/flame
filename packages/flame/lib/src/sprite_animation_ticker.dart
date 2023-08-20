import 'dart:async';

import 'package:flame/components.dart';
import 'package:meta/meta.dart';

/// A helper class to make the [spriteAnimation] tick.
class SpriteAnimationTicker {
  SpriteAnimationTicker(this.spriteAnimation);

  // The current sprite animation.
  final SpriteAnimation spriteAnimation;

  /// Index of the current frame that should be displayed.
  int currentIndex = 0;

  /// Current clock time (total time) of this animation, in seconds, since last
  /// frame.
  ///
  /// It's ticked by the update method. It's reset every frame change.
  double clock = 0.0;

  /// Total elapsed time of this animation, in seconds, since start or a reset.
  double elapsed = 0.0;

  /// Registered method to be triggered when the animation starts.
  void Function()? onStart;

  /// Registered method to be triggered when the animation frame updates.
  void Function(int currentIndex)? onFrame;

  /// Registered method to be triggered when the animation complete.
  void Function()? onComplete;

  @visibleForTesting
  Completer<void>? completeCompleter;

  /// The current frame that should be displayed.
  SpriteAnimationFrame get currentFrame => spriteAnimation.frames[currentIndex];

  /// Returns whether the animation is on the first frame.
  bool get isFirstFrame => currentIndex == 0;

  /// Returns whether the animation is on the last frame.
  bool get isLastFrame => currentIndex == spriteAnimation.frames.length - 1;

  /// Returns whether the animation has only a single frame (and is, thus, a
  /// still image).
  bool get isSingleFrame => spriteAnimation.frames.length == 1;

  bool _paused = false;

  /// Returns current value of paused flag.
  bool get isPaused => _paused;

  /// Sets the given value of paused flag.
  set paused(bool value) {
    _paused = value;
  }

  /// A future that will complete when the animation completes.
  ///
  /// An animation is considered to be completed if it reaches its [isLastFrame]
  /// and is not looping.
  Future<void> get completed {
    if (_done) {
      return Future.value();
    }

    completeCompleter ??= Completer<void>();

    return completeCompleter!.future;
  }

  /// Resets the animation, like it would just have been created.
  void reset() {
    clock = 0.0;
    elapsed = 0.0;
    currentIndex = 0;
    _done = false;
    _started = false;
    _paused = false;

    // Reset completeCompleter if it's already completed
    if (completeCompleter?.isCompleted ?? false) {
      completeCompleter = null;
    }
  }

  /// Sets this animation to be on the last frame.
  void setToLast() {
    currentIndex = spriteAnimation.frames.length - 1;
    clock = spriteAnimation.frames[currentIndex].stepTime;
    elapsed = totalDuration();
    update(0);
  }

  /// Computes the total duration of this animation
  /// (before it's done or repeats).
  double totalDuration() {
    return spriteAnimation.frames
        .map((f) => f.stepTime)
        .reduce((a, b) => a + b);
  }

  /// Gets the current [Sprite] that should be shown.
  ///
  /// In case it reaches the end:
  /// If loop is true, it will return the last sprite. Otherwise, it will
  /// go back to the first.
  Sprite getSprite() {
    return currentFrame.sprite;
  }

  /// If loop is false, returns whether the animation is done (fixed in the
  /// last Sprite).
  ///
  /// Always returns false otherwise.
  bool _done = false;
  bool done() => _done;

  /// Local flag to determine if the animation has started to prevent multiple
  /// calls to [onStart].
  bool _started = false;

  /// Updates this animation, if not paused, ticking the lifeTime by an amount
  /// [dt] (in seconds).
  void update(double dt) {
    if (_paused) {
      return;
    }
    clock += dt;
    elapsed += dt;
    if (_done) {
      return;
    }
    if (!_started) {
      onStart?.call();
      onFrame?.call(currentIndex);
      _started = true;
    }

    while (clock >= currentFrame.stepTime) {
      if (isLastFrame) {
        if (spriteAnimation.loop) {
          clock -= currentFrame.stepTime;
          currentIndex = 0;
          onFrame?.call(currentIndex);
        } else {
          _done = true;
          onComplete?.call();
          completeCompleter?.complete();
          return;
        }
      } else {
        clock -= currentFrame.stepTime;
        currentIndex++;
        onFrame?.call(currentIndex);
      }
    }
  }
}
