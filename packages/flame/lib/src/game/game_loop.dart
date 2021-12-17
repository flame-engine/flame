import 'package:flutter/scheduler.dart';

class GameLoop {
  void Function(double dt) callback;
  Duration _previous = Duration.zero;
  late final Ticker _ticker;

  GameLoop(this.callback) {
    _ticker = Ticker(_tick);
  }

  void _tick(Duration timestamp) {
    final durationDelta = timestamp - _previous;
    final dt = durationDelta.inMicroseconds / Duration.microsecondsPerSecond;
    _previous = timestamp;
    callback(dt);
  }

  void start() {
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void stop() {
    _ticker.stop();
    _previous = Duration.zero;
  }

  void dispose() {
    _ticker.dispose();
  }

  @Deprecated('Internal variable')
  Duration get previous => _previous;

  @Deprecated('Use stop() instead')
  void pause() => stop();

  @Deprecated('Use start() instead')
  void resume() => start();
}
