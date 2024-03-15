import 'dart:ui';

import 'package:flame/game.dart';

/// A mixin that adds performance tracking to a game.
mixin HasPerformanceTracker on Game {
  int _updateTime = 0;
  int _renderTime = 0;
  final _stopwatch = Stopwatch();

  /// The time it took to update the game in milliseconds.
  int get updateTime => _updateTime;

  /// The time it took to render the game in milliseconds.
  int get renderTime => _renderTime;

  @override
  void update(double dt) {
    _stopwatch.reset();
    _stopwatch.start();
    super.update(dt);
    _stopwatch.stop();
    _updateTime = _stopwatch.elapsedMilliseconds;
  }

  @override
  void render(Canvas canvas) {
    _stopwatch.reset();
    _stopwatch.start();
    super.render(canvas);
    _stopwatch.stop();
    _renderTime = _stopwatch.elapsedMilliseconds;
  }
}
