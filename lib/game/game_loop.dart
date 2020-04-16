import 'package:flutter/scheduler.dart';

class GameLoop {
  Function callback;
  int _frameCallbackId;
  bool _running = false;
  Duration previous = Duration.zero;

  GameLoop(this.callback);

  void scheduleTick() {
    _running = true;
    _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_tick);
  }

  void unscheduleTick() {
    _running = false;
    if (_frameCallbackId != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackId);
    }
  }

  void _tick(Duration timestamp) {
    if (!_running) {
      return;
    }
    scheduleTick();
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

  void pause() {
    if (_running) {
      previous = Duration.zero;
      unscheduleTick();
    }
  }

  void resume() {
    if (!_running) {
      scheduleTick();
    }
  }
}
