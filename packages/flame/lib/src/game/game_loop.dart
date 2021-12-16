import 'package:flutter/scheduler.dart';

/// Internal class that drives the game loop by calling the provided [callback]
/// function on every Flutter animation frame.
///
/// After creating a GameLoop, call `start()` in order to make it actually run.
/// When a GameLoop object is no longer needed, it must be `dispose()`d.
///
/// For example:
/// ```dart
/// final gameLoop = GameLoop(onGameLoopTick);
/// gameLoop.start();
/// ...
/// gameLoop.dispose();
/// ```
class GameLoop {
  GameLoop(this.callback) {
    _ticker = Ticker(_tick);
  }

  /// Function to be called on every Flutter rendering frame.
  ///
  /// This function takes a single parameter `dt`, which is the amount of time
  /// passed since the previous invocation of this function. The time is
  /// measured in seconds, with microsecond precision. The argument will be
  /// equal to 0 on first invocation of the callback.
  void Function(double dt) callback;

  /// Total amount of time passed since the game loop was started.
  ///
  /// This variable is updated on every rendering frame, just before the
  /// [callback] is invoked. It will be equal to zero while the game loop is
  /// stopped. It is also guaranteed to be equal to zero on the first invocation
  /// of the callback.
  Duration currentTime = Duration.zero;

  /// Internal object responsible for periodically calling the [callback]
  /// function.
  late Ticker _ticker;

  /// This method is periodically invoked by the [_ticker].
  void _tick(Duration timestamp) {
    final delta = timestamp - currentTime;
    final dt = delta.inMicroseconds / Duration.microsecondsPerSecond;
    currentTime = timestamp;
    callback(dt);
  }

  /// Start running the game loop. The game loop is created in a paused state,
  /// so this must be called once in order to make the loop running. Calling
  /// this method again when the game loop already runs is a noop.
  void start() {
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  /// Stop the game loop. While it is stopped, the time "freezes". When the
  /// game loop is started again, the [callback] will NOT be made aware that
  /// any amount of time has passed.
  void stop() {
    _ticker.stop();
    currentTime = Duration.zero;
  }

  /// Call this before deleting the [GameLoop] object.
  ///
  /// The [GameLoop] will no longer be usable after this method is called. You
  /// do not have to stop the game loop before disposing of it.
  void dispose() {
    _ticker.dispose();
  }

  @Deprecated('Use stop() instead')
  void pause() => stop();

  @Deprecated('Use start() instead')
  void resume() => start();
}
