import 'package:flutter/scheduler.dart';

class GameLoop {
  void Function(double dt) callback;
  Duration previous = Duration.zero;
  late Ticker _ticker;

  GameLoop(this.callback) {
    _ticker = Ticker(_tick);
  }

  void _tick(Duration timestamp) {
    final durationDelta = timestamp - previous;
    final dt = durationDelta.inMicroseconds / Duration.microsecondsPerSecond;
    previous = timestamp;
    callback(dt);
  }

  void start() {
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void stop() {
    _ticker.stop();
    previous = Duration.zero;
  }

  void dispose() {
    _ticker.dispose();
  }

  @Deprecated('Use stop() instead')
  void pause() => stop();

  @Deprecated('Use start() instead')
  void resume() => start();
}
