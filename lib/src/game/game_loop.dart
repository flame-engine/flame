import 'package:flutter/scheduler.dart';

class GameLoop {
  Function callback;
  Duration previous = Duration.zero;
  Ticker _ticker;

  GameLoop(this.callback) {
    _ticker = Ticker(_tick);
  }

  void _tick(Duration timestamp) {
    final double dt = _computeDeltaT(timestamp);
    callback(dt);
  }

  double _computeDeltaT(Duration now) {
    Duration delta = now - previous;
    if (previous == Duration.zero) {
      delta = Duration.zero;
    }
    previous = now;
    return delta.inMicroseconds / Duration.microsecondsPerSecond;
  }

  void start() {
    _ticker.start();
  }

  void stop() {
    _ticker.stop();
  }

  void pause() {
    _ticker.muted = true;
    previous = Duration.zero;
  }

  void resume() {
    _ticker.muted = false;
  }
}
