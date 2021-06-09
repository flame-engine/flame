import 'package:flutter/scheduler.dart';

class GameLoop {
  void Function(double dt) callback;
  Duration previous = Duration.zero;
  late Ticker _ticker;

  GameLoop(this.callback) {
    _ticker = Ticker(_tick);
  }

  void _tick(Duration timestamp) {
    final dt = _computeDeltaT(timestamp);
    callback(dt);
  }

  double _computeDeltaT(Duration now) {
    final delta = previous == Duration.zero ? Duration.zero : now - previous;
    previous = now;
    return delta.inMicroseconds / Duration.microsecondsPerSecond;
  }

  void start() {
    _ticker.start();
  }

  void stop() {
    _ticker.stop();
  }

  void dispose() {
    _ticker.dispose();
  }

  void pause() {
    _ticker.muted = true;
    previous = Duration.zero;
  }

  void resume() {
    _ticker.muted = false;
  }
}
