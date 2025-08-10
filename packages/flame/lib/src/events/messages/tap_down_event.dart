import 'package:flame/extensions.dart';
import 'package:flame/src/events/component_mixins/tap_callbacks.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flame/src/events/messages/tap_cancel_event.dart';
import 'package:flame/src/events/messages/tap_up_event.dart';
import 'package:flutter/gestures.dart';

/// The event propagated through the Flame engine when the user starts a touch
/// on the game canvas.
///
/// This is a [PositionEvent], where the position is the point of touch.
///
/// In order for a component to be eligible to receive this event, it must add
/// the [TapCallbacks] mixin.
class TapDownEvent extends PositionEvent {
  TapDownEvent(this.pointerId, super.game, TapDownDetails details)
    : deviceKind = details.kind ?? PointerDeviceKind.unknown,
      super(
        devicePosition: details.globalPosition.toVector2(),
      );

  /// The unique identifier of the tap event.
  ///
  /// Subsequent [TapUpEvent] or [TapCancelEvent] will carry the same pointer
  /// id. This allows distinguishing multiple taps that may occur simultaneously
  /// on the same component.
  final int pointerId;

  final PointerDeviceKind deviceKind;

  @override
  String toString() =>
      'TapDownEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'pointerId: $pointerId, deviceKind: $deviceKind)';
}
