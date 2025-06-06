import 'dart:math';
import 'dart:ui';

/// Simple utility class that helps handling time counting and implementing
/// interval like events.
///
/// Timer auto-starts by default.
///
/// NOTE: You can change the [limit], but keep in mind that the timer
/// won't start automatically if the limit is raised and the timer currently
/// is stopped.
class Timer {
  double limit;
  VoidCallback? onTick;
  bool repeat;
  double _current = 0;
  bool _running;
  final int? tickCount;
  int _currentTick = 0;

  Timer(
    this.limit, {
    this.onTick,
    this.repeat = false,
    bool autoStart = true,
    this.tickCount,
  })  : assert(
          tickCount == null || tickCount > 0,
          'tickCount must be null or bigger than 0',
        ),
        _running = autoStart;

  /// The current amount of seconds that has passed on this iteration
  double get current => _current;

  /// If the timer is finished, timers that repeat never finish
  bool get finished =>
      (_current >= limit && !repeat) ||
      (tickCount != null && _currentTick >= tickCount!);

  /// Whether the timer is running or not
  bool isRunning() => _running;

  /// A value between 0.0 and 1.0 indicating the timer progress
  double get progress => min(_current / limit, 1.0);

  void update(double dt) {
    if (_running) {
      _current += dt;
      if (_current >= limit) {
        if (!repeat) {
          _running = false;
          _callTicker();
          return;
        }
        // This is used to cover the rare case of _current being more than
        // two times the value of limit, so that the onTick is called the
        // correct number of times
        while (_current >= limit) {
          _current -= limit;
          _callTicker();
        }
      }
    }
  }

  void _callTicker() {
    onTick?.call();
    _currentTick += 1;
    if (tickCount != null && _currentTick >= tickCount!) {
      stop();
    }
  }

  /// Start the timer from 0.
  void start() {
    reset();
    resume();
  }

  /// Stop and reset the timer.
  void stop() {
    reset();
    pause();
  }

  /// Reset the timer to 0, but continue running if it currently is running.
  void reset() {
    _current = 0;
  }

  ///  Pause the timer (no-op if it is already paused).
  void pause() {
    _running = false;
  }

  /// Resume a paused timer (no-op if it is already running).
  void resume() {
    _running = true;
  }
}
