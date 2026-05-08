import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flutter/gestures.dart';

/// The event propagated through the Flame engine when the user completes
/// a long press gesture (i.e. the pointer has been held down long enough
/// to be recognized as a long press).
///
/// This is a [PositionEvent], where the position is the point of contact.
class LongPressStartEvent extends PositionEvent<LongPressStartDetails> {
  LongPressStartEvent(this.pointerId, super.game, LongPressStartDetails details)
    : super(
        raw: details,
        devicePosition: details.globalPosition.toVector2(),
      );

  /// The unique identifier for this long press gesture.
  ///
  /// Subsequent move update, end, or cancel events will carry the same
  /// pointer id.
  final int pointerId;

  @override
  String toString() =>
      'LongPressStartEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'pointerId: $pointerId)';
}
