import 'dart:async';

/// Calls [poll] every [interval] while [isActive] returns true.
///
/// A new poll isn't started while the previous one is still running, so a poll
/// that takes longer than the interval doesn't make the calls pile up.
class Poller({
  required final Duration interval,
  required final Future<void> Function() poll,
  required final bool Function() isActive,
}) {
  Timer? _timer;
  var _isPolling = false;

  /// Whether a poll is running right now.
  bool get isPolling => _isPolling;

  /// Starts polling, if it isn't already started.
  void start() {
    _timer ??= Timer.periodic(interval, (_) => _tick());
  }

  /// Stops polling. A poll that is already running is not interrupted.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _tick() async {
    if (_isPolling || !isActive()) {
      return;
    }
    _isPolling = true;
    try {
      await poll();
    } on Object {
      // A failed poll, for example because the game was disconnected or the
      // component was removed in the meantime, is retried on the next tick.
    } finally {
      _isPolling = false;
    }
  }
}
