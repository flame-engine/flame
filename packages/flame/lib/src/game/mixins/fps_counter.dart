import 'dart:collection';

import 'package:flame/game.dart';

const _maxFrames = 60;
const frameInterval =
    Duration(microseconds: Duration.microsecondsPerSecond ~/ _maxFrames);

@Deprecated(
  'Use FPSComponent or FPSTextComponent instead. '
  'FPSCounter will be removed in v1.3.0',
)
mixin FPSCounter on Game {
  /// The sliding window size, i.e. the number of game ticks over which the fps
  /// measure will be averaged.
  final int windowSize = 60;

  /// The queue of the recent game tick durations.
  /// The length of this queue will not exceed [windowSize].
  final Queue<double> window = Queue();

  /// The sum of all values in the [window] queue.
  double _sum = 0;

  @override
  void update(double dt) {
    window.addLast(dt);
    _sum += dt;
    if (window.length > windowSize) {
      _sum -= window.removeFirst();
    }
  }

  /// Get the current average FPS over the last [windowSize] frames.
  double fps([int average = 1]) {
    return window.isEmpty ? 0 : window.length / _sum;
  }
}
