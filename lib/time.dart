
class Timer {
  final double _limit;
  void Function() _callback;
  double _current;
  bool _running = false;

  Timer(this._limit, this._callback);

  void update(double dt) {
    if (_running) {
      _current += dt;

      if (isFinished()) {
        _running = false;
        _callback();
      }
    }
  }

  bool isFinished() {
    return _current >= _limit;
  }

  void start() {
    _current = 0;
    _running = true;
  }

  void stop() {
    _current = 0;
    _running = false;
  }
}
