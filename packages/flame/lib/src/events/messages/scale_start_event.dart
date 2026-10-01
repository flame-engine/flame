import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/gestures.dart';

/// The event propagated through the Flame engine when the user starts a scale
/// (pinch/zoom) gesture on the game canvas.
///
/// This is a [PositionEvent], where the position is the focal point of the
///  gesture.
class ScaleStartEvent(
  /// The unique identifier of the scale event.
  ///
  /// Subsequent [ScaleUpdateEvent] or [ScaleEndEvent] will carry the same
  /// pointer id. This allows distinguishing multiple simultaneous scale
  /// gestures.
  ///
  final int pointerId,
  super.game,
  ScaleStartDetails details,
) extends PositionEvent<ScaleStartDetails> {
  this
    : super(
        raw: details,
        devicePosition: details.focalPoint.toVector2(),
      );

  /// The type of device that initiated the gesture.
  final PointerDeviceKind deviceKind =
      details.kind ?? PointerDeviceKind.unknown;

  @override
  String toString() =>
      'ScaleStartEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'pointerId: $pointerId, deviceKind: $deviceKind)';
}
