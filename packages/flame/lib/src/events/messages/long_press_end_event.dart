import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flutter/gestures.dart';

/// The event propagated through the Flame engine when a long press gesture
/// ends (the user lifts their pointer after a long press).
///
/// This is a [PositionEvent], where the position is the point where the
/// pointer was lifted.
class LongPressEndEvent extends PositionEvent<LongPressEndDetails> {
  LongPressEndEvent(this.pointerId, super.game, LongPressEndDetails details)
    : velocity = details.velocity.pixelsPerSecond.toVector2(),
      super(
        raw: details,
        devicePosition: details.globalPosition.toVector2(),
      );

  /// The unique identifier for this long press gesture.
  final int pointerId;

  /// The velocity of the pointer at the time the long press ended.
  final Vector2 velocity;

  @override
  String toString() =>
      'LongPressEndEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'pointerId: $pointerId, velocity: $velocity)';
}
