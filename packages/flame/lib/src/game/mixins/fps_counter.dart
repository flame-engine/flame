import 'package:flutter/scheduler.dart';

import '../../../game.dart';

const _maxFrames = 60;
const frameInterval =
    Duration(microseconds: Duration.microsecondsPerSecond ~/ _maxFrames);

mixin FPSCounter on Game {
  List<FrameTiming> _previousTimings = [];

  @override
  void onTimingsCallback(List<FrameTiming> timings) =>
      _previousTimings = timings;

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
