import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flutter/gestures.dart';

/// The event propagated through the Flame engine when the user starts a scale
/// (pinch/zoom) gesture on the game canvas.
///
/// This is a [PositionEvent], where the position is the focal point of the
///  gesture.
class ScaleStartEvent extends PositionEvent<ScaleStartDetails> {
  ScaleStartEvent(this.pointerId, super.game, ScaleStartDetails details)
    : deviceKind = details.kind ?? PointerDeviceKind.unknown,
      super(
        raw: details,
        devicePosition: details.focalPoint.toVector2(),
      );

  /// The unique identifier of the scale event.
  ///
  /// Subsequent [ScaleUpdateEvent] or [ScaleEndEvent] will carry the same
  /// pointer id. This allows distinguishing multiple simultaneous scale
  /// gestures.
  ///
  final int pointerId;

  /// The type of device that initiated the gesture.
  final PointerDeviceKind deviceKind;

  @override
  String toString() =>
      'ScaleStartEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'pointerId: $pointerId, deviceKind: $deviceKind)';
}
