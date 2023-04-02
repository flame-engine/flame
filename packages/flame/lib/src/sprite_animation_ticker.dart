import 'dart:async';

import 'package:flame/components.dart';

/// A helper class to make the [spriteAnimation] tick.
class SpriteAnimationTicker {
  // The current sprite animation.
  late SpriteAnimation _spriteAnimation;

  /// Returns the current sprite animation.
  SpriteAnimation get spriteAnimation => _spriteAnimation;

  /// Sets the given sprite animation as current.
  set spriteAnimation(SpriteAnimation value) {
    _spriteAnimation = value;
    reset();
  }

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

  Completer<void>? _completeCompleter;

  /// The current frame that should be displayed.
  SpriteAnimationFrame get currentFrame =>
      _spriteAnimation.frames[currentIndex];

  /// Returns whether the animation is on the first frame.
  bool get isFirstFrame => currentIndex == 0;

  /// Returns whether the animation is on the last frame.
  bool get isLastFrame => currentIndex == _spriteAnimation.frames.length - 1;

  /// Returns whether the animation has only a single frame (and is, thus, a
  /// still image).
  bool get isSingleFrame => _spriteAnimation.frames.length == 1;

  /// A future that will complete when the animation completes.
  ///
  /// An animation is considered to be completed if it reaches its [isLastFrame]
  /// and is not looping.
  Future<void> get completed {
    if (_done) {
      return Future.value();
    }

    _completeCompleter ??= Completer<void>();

    return _completeCompleter!.future;
  }

  /// Resets the animation, like it would just have been created.
  void reset() {
    clock = 0.0;
    elapsed = 0.0;
    currentIndex = 0;
    _done = false;
    _started = false;
  }

  /// Sets this animation to be on the last frame.
  void setToLast() {
    currentIndex = _spriteAnimation.frames.length - 1;
    clock = _spriteAnimation.frames[currentIndex].stepTime;
    elapsed = totalDuration();
    update(0);
  }

  /// Computes the total duration of this animation
  /// (before it's done or repeats).
  double totalDuration() {
    return _spriteAnimation.frames
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

  /// Updates this animation, ticking the lifeTime by an amount [dt]
  /// (in seconds).
  void update(double dt) {
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
        if (_spriteAnimation.loop) {
          clock -= currentFrame.stepTime;
          currentIndex = 0;
          onFrame?.call(currentIndex);
        } else {
          _done = true;
          onComplete?.call();
          _completeCompleter?.complete();
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
