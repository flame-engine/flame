import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/drag_end_event.dart';
import 'package:flame/src/events/messages/drag_update_event.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flutter/gestures.dart';

/// The event propagated through the Flame engine when the user starts a drag
/// gesture on the game canvas.
///
/// This is a [PositionEvent], where the position is the point of touch.
class DragStartEvent extends PositionEvent {
  DragStartEvent(this.pointerId, super.game, DragStartDetails details)
    : deviceKind = details.kind ?? PointerDeviceKind.unknown,
      super(
        devicePosition: details.globalPosition.toVector2(),
      );

  /// The unique identifier of the drag event.
  ///
  /// Subsequent [DragUpdateEvent] or [DragEndEvent] will carry the same pointer
  /// id. This allows distinguishing multiple drags that may occur at the same
  /// time on the same component.
  final int pointerId;

  final PointerDeviceKind deviceKind;

  @override
  String toString() =>
      'DragStartEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'pointedId: $pointerId, deviceKind: $deviceKind)';
}
