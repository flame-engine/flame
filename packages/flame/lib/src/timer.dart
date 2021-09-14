import 'dart:math';
import 'dart:ui';

import 'components/component.dart';

/// Simple utility class that helps handling time counting and implementing
/// interval like events.
class Timer {
  final double limit;
  VoidCallback? callback;
  bool repeat;
  double _current = 0;
  bool _running = false;

  Timer(this.limit, {this.callback, this.repeat = false});

  /// The current amount of ms that has passed on this iteration
  double get current => _current;

  /// If the timer is finished, timers that repeat never finish
  bool get finished => _current >= limit && !repeat;

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
          callback?.call();
          return;
        }
        // This is used to cover the rare case of _current being more than
        // two times the value of limit, so that the callback is called the
        // correct number of times
        while (_current >= limit) {
          _current -= limit;
          callback?.call();
        }
      }
    }
  }

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
}

/// Simple component which wraps a [Timer] instance allowing it to be easily
/// used inside a FlameGame game.
class TimerComponent extends Component {
  Timer timer;

  TimerComponent(this.timer);

  @override
  void update(double dt) {
    super.update(dt);
    timer.update(dt);
  }

  @override
  void render(Canvas canvas) {}

  @override
  bool get shouldRemove => timer.finished;
}
