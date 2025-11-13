import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';

/// Interface that must be implemented by a game in order for it to be eligible
/// to receive events from an [ScaleGestureRecognizer].
///
/// Instead of implementing this class directly consider using one of the
/// prebuilt mixins:
///  - [MultiTouchDragDetector] for a custom `Game`
abstract class ScaleListener {
  /// The beginning of a drag operation.
  ///
  /// If the game is not listening to tap events, this event will occur as soon
  /// as the user touches the screen. If the game uses both a [MultiTapListener]
  /// and a [MultiDragListener] simultaneously, then this event will fire once
  /// the user moves their finger away from the point of the initial touch.
  void handleScaleStart(ScaleStartDetails details);

  /// The pointer that was touching the screen has moved.
  ///
  /// This event occurs frequently during the drag, allowing you to keep track
  /// of the position of the point of touch as it moves. This event will only
  /// fire when the point of touch moves, and not when it stays still.
  void handleScaleUpdate(ScaleUpdateDetails details);

  /// Marks the end of a drag operation.
  ///
  /// This event fires when the pointer stops touching the screen. It will fire
  /// even if the pointer is currently outside of the game widget.
  void handleScaleEnd(ScaleEndDetails details);
}
