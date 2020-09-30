import 'package:flutter/scheduler.dart';

import 'game/game.dart';

const _maxFrames = 60;
const frameInterval =
    Duration(microseconds: Duration.microsecondsPerSecond ~/ _maxFrames);

mixin FPSCounter on Game {
  List<FrameTiming> _previousTimings = [];

  @override
  void onTimingsCallback(List<FrameTiming> timings) =>
      _previousTimings = timings;

  /// Returns whether this [Game] is should record fps or not.
  ///
  /// Returns `false` by default. Override to use the `fps` counter method.
  /// In recording fps, the [recordDt] method actually records every `dt` for statistics.
  /// Then, you can use the [fps] method to check the game FPS.
  @Deprecated('Flame is now using Flutter frame times, will be removed in v1')
  bool recordFps();

  /// Returns the FPS based on the frame times from [onTimingsCallback].
  double fps([int average = 1]) {
    return _previousTimings.length *
        _maxFrames /
        _previousTimings.map((t) {
          return (t.totalSpan.inMicroseconds ~/ frameInterval.inMicroseconds) +
              1;
        }).fold(0, (a, b) => a + b);
  }
}
