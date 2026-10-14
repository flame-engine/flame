import 'dart:async';

import 'package:flame_svg/svg_paths_animation.dart';
import 'package:flutter/foundation.dart' show listEquals, visibleForTesting;

/// A helper class to make the [animation] tick.
class SvgPathsAnimationTicker(final SvgPathsAnimation animation) {
  /// Create a ticker for the given [animation].
  this;

  /// The time within the current loop, in seconds.
  double clock = 0.0;

  /// Total elapsed time of this animation, in seconds, since start or a reset.
  double elapsed = 0.0;

  /// Called when the animation starts.
  void Function()? onStart;

  /// Called with the [currentIndices] when they change, and when the
  /// animation starts.
  void Function(List<int> currentIndices)? onFrame;

  /// Called when the animation completes.
  void Function()? onComplete;

  /// Completes the [completed] future.
  @visibleForTesting
  Completer<void>? completeCompleter;

  /// The indices of the frames currently shown, in the order of the frames,
  /// in a list that can not be modified.
  List<int> get currentIndices => _currentIndices;
  late List<int> _currentIndices = animation.indicesAt(0);

  /// The frames currently shown.
  Iterable<SvgPathsAnimationFrame> get currentFrames =>
      _currentIndices.map((i) => animation.frames[i]);

  /// Whether the animation is paused.
  bool paused = false;

  /// A future that completes when the animation completes, which only happens
  /// if it does not loop.
  Future<void> get completed {
    if (_done) {
      return Future.value();
    }
    completeCompleter ??= Completer<void>();
    return completeCompleter!.future;
  }

  /// The duration of each loop, in seconds.
  double totalDuration() => animation.duration;

  /// Whether the animation is done, which only happens if it does not loop.
  bool done() => _done;

  bool _done = false;
  bool _started = false;
  bool _firstLoop = true;

  /// Resets the animation, like it would just have been created.
  void reset() {
    clock = 0.0;
    elapsed = 0.0;
    _done = false;
    _started = false;
    _firstLoop = true;
    paused = false;
    _currentIndices = animation.indicesAt(0);
    if (completeCompleter?.isCompleted ?? false) {
      completeCompleter = null;
    }
  }

  /// Sets this animation to the end of its loop, even if paused. An animation
  /// that loops then starts its next loop, like a `SpriteAnimationTicker`.
  void setToLast() {
    clock = animation.duration;
    elapsed = animation.duration;
    _advance();
  }

  /// Updates this animation, if not paused, ticking it by [dt] seconds.
  void update(double dt) {
    if (paused) {
      return;
    }
    clock += dt;
    elapsed += dt;
    _advance();
  }

  /// Shows the frames at the [clock], handling the start, loop and end.
  void _advance() {
    if (_done) {
      return;
    }
    if (!_started) {
      _started = true;
      onStart?.call();
      onFrame?.call(_currentIndices);
    }
    final duration = animation.duration;
    if (clock >= duration) {
      if (animation.loop) {
        clock %= duration;
        _firstLoop = false;
      } else {
        clock = duration;
        _done = true;
      }
    }
    _show(animation.indicesAt(clock, firstLoop: _firstLoop));
    if (_done) {
      onComplete?.call();
      completeCompleter?.complete();
    }
  }

  void _show(List<int> indices) {
    if (!listEquals(indices, _currentIndices)) {
      _currentIndices = indices;
      onFrame?.call(indices);
    }
  }
}
