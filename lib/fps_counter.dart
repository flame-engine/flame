import 'dart:math' as math;

import 'game/game.dart';

mixin FPSCounter on Game {
  /// List of deltas used in debug mode to calculate FPS
  final List<double> _dts = [];

  /// Returns whether this [Game] is should record fps or not
  ///
  /// Returns `false` by default. Override to use the `fps` counter method.
  /// In recording fps, the [recordDt] method actually records every `dt` for statistics.
  /// Then, you can use the [fps] method to check the game FPS.
  bool recordFps();

  /// This is a hook that comes from the RenderBox to allow recording of render times and statistics.
  @override
  void recordDt(double dt) {
    if (recordFps()) {
      _dts.add(dt);
    }
  }

  /// Returns the average FPS for the last [average] measures.
  ///
  /// The values are only saved if in debug mode (override [recordFps] to use this).
  /// Selects the last [average] dts, averages then, and returns the inverse value.
  /// So it's technically updates per second, but the relation between updates and renders is 1:1.
  /// Returns 0 if empty.
  double fps([int average = 1]) {
    final List<double> dts = _dts.sublist(math.max(0, _dts.length - average));
    if (dts.isEmpty) {
      return 0.0;
    }
    final double dtSum = dts.reduce((s, t) => s + t);
    final double averageDt = dtSum / average;
    return 1 / averageDt;
  }
}
