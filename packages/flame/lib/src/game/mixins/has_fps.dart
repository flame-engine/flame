import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';

import '../../../game.dart';

const _maxFrames = 60.0;
const frameInterval =
    Duration(microseconds: Duration.microsecondsPerSecond ~/ _maxFrames);

@Deprecated(
  'This will be removed in favor of `HasFPS` in v1.3.0',
)
mixin FPSCounter on Game {
  List<FrameTiming> _previousTimings = [];

  @override
  void onTimingsCallback(List<FrameTiming> timings) =>
      _previousTimings = timings;

  /// Returns the FPS based on the frame times from [onTimingsCallback].
  double fps([int average = 1]) {
    return min(
      Duration.microsecondsPerSecond /
          (_previousTimings.map((t) => t.totalSpan.inMicroseconds).sum /
              _previousTimings.length),
      _maxFrames,
    );
  }
}

mixin HasFPS on Game {
  List<FrameTiming> _previousTimings = [];

  @override
  void onTimingsCallback(List<FrameTiming> timings) =>
      _previousTimings = timings;

  /// Returns the FPS based on the frame times from [onTimingsCallback].
  double get fps {
    return min(
      Duration.microsecondsPerSecond /
          (_previousTimings.map((t) => t.totalSpan.inMicroseconds).sum /
              _previousTimings.length),
      _maxFrames,
    );
  }
}
