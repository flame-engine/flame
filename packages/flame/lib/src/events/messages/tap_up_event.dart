import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flame/src/events/messages/tap_down_event.dart';
import 'package:flutter/gestures.dart';

/// The event propagated through the Flame engine when the user stops touching
/// the game canvas.
///
/// This is a [PositionEvent], where the position is the point where the touch
/// has last occurred.
///
/// The [TapUpEvent] will only occur if there was a previous [TapDownEvent].
class TapUpEvent extends PositionEvent {
  TapUpEvent(this.pointerId, super.game, TapUpDetails details)
      : deviceKind = details.kind,
        super(
          devicePosition: details.globalPosition.toVector2(),
        );

  /// The id of the previous [TapDownEvent] to which this event corresponds.
  final int pointerId;

  final PointerDeviceKind deviceKind;

  @override
  String toString() => 'TapUpEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'pointerId: $pointerId, deviceKind: $deviceKind)';
}
