/// Simple utility class that helps handling time counting and implementing interval like events.
///
class Timer {
  final double _limit;
  void Function() _callback;
  bool _repeat;
  double _current = 0;
  bool _running = false;

  Timer(this._limit, {bool repeat = false, void Function() callback}) {
    _repeat = repeat;
    _callback = callback;
  }

  double get current => _current;

  void update(double dt) {
    if (_running) {
      _current += dt;

      if (isFinished()) {
        if (_repeat) {
          _current -= _limit;
        } else {
          _running = false;
        }

        if (_callback != null) {
          _callback();
        }
      }
    }
  }

  bool isFinished() {
    return _current >= _limit;
  }

  bool isRunning() => _running;

  void start() {
    _current = 0;
    _running = true;
  }

  void stop() {
    _current = 0;
    _running = false;
  }

  void pause() {
    _running = false;
  }

  void resume() {
    _running = true;
  }

  /// A value between 0 and 1 indicating the timer progress
  double get progress => _current / _limit;
}
