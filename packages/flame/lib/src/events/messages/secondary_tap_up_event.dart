import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flame/src/events/messages/secondary_tap_down_event.dart';
import 'package:flutter/gestures.dart';

/// The event propagated through the Flame engine when the user stops secondary
/// touching (i.e. right mouse button) the game canvas.
///
/// This is a [PositionEvent], where the position is the point where the touch
/// has last occurred.
///
/// The [SecondaryTapUpEvent] will only occur if there was a previous
/// [SecondaryTapDownEvent].
class SecondaryTapUpEvent extends PositionEvent<TapUpDetails> {
  SecondaryTapUpEvent(super.game, TapUpDetails details)
    : deviceKind = details.kind,
      super(
        raw: details,
        devicePosition: details.globalPosition.toVector2(),
      );

  final PointerDeviceKind deviceKind;

  @override
  String toString() =>
      'SecondaryTapUpEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'deviceKind: $deviceKind)';
}
