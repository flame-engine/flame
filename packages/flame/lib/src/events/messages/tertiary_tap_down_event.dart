import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flutter/gestures.dart';

/// The event propagated through the Flame engine when the user starts a
/// tertiary touch (i.e. middle mouse click) on the game canvas.
///
/// This is a [PositionEvent], where the position is the point of touch.
///
/// In order for a component to be eligible to receive this event, it must add
/// the [TertiaryTapCallbacks] mixin.
class TertiaryTapDownEvent extends PositionEvent<TapDownDetails> {
  TertiaryTapDownEvent(super.game, TapDownDetails details)
    : deviceKind = details.kind ?? PointerDeviceKind.unknown,
      super(
        raw: details,
        devicePosition: details.globalPosition.toVector2(),
      );

  final PointerDeviceKind deviceKind;

  @override
  String toString() =>
      'TertiaryTapDownEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'deviceKind: $deviceKind)';
}
