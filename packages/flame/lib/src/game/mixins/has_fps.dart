import 'package:flutter/scheduler.dart';

import '../../../game.dart';

const _maxFrames = 60;
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
    return _previousTimings.length *
        _maxFrames /
        _previousTimings.map((t) {
          return (t.totalSpan.inMicroseconds ~/ frameInterval.inMicroseconds) +
              1;
        }).fold(0, (a, b) => a + b);
  }
}

mixin HasFPS on Game {
  List<Duration> _timings = [];

  Duration? _prev;

  @override
  void onPostFrameCallback(Duration duration) {
    if (_prev != null) {
      _timings.add(duration - _prev!);
      if (_timings.length > _maxFrames) {
        _timings = _timings.sublist(_timings.length - _maxFrames - 1);
      }
    }

    _prev = duration;

    if (isAttached) {
      SchedulerBinding.instance!.addPostFrameCallback(onPostFrameCallback);
    }
  }

  /// Returns the FPS based on the durations from [onPostFrameCallback].
  double get fps => _timings.isEmpty ? 0 : 1000 / _timings.last.inMilliseconds;
}
