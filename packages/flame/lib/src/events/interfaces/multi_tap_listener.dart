import 'package:flame/src/game/mixins/has_tappables.dart';
import 'package:flame/src/game/mixins/multi_touch_tap_detector.dart';
import 'package:flutter/gestures.dart';

/// Interface that must be implemented by a game in order for it to be eligible
/// to receive events from a [MultiTapGestureRecognizer].
///
/// Instead of implementing this class directly consider using one of the
/// prebuilt mixins:
///  - [HasTappables] for a `FlameGame`
///  - [MultiTouchTapDetector] for a custom `Game`
abstract class MultiTapListener {
  /// The amount of time before the "long tap down" event is triggered.
  double get longTapDelay;

  /// A tap has occurred.
  void handleTap(int pointerId);

  /// A pointer has touched the screen.
  void handleTapDown(int pointerId, TapDownDetails details);

  /// A pointer stopped contacting the screen.
  void handleTapUp(int pointerId, TapUpDetails details);

  /// A pointer that already triggered [handleTapDown] will not trigger
  /// [handleTap].
  void handleTapCancel(int pointerId);

  /// A pointer that has previously triggered [handleTapDown] is still touching
  /// the screen after [longTapDelay] seconds.
  void handleLongTapDown(int pointerId, TapDownDetails details);
}
