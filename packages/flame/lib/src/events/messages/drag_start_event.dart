import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/gestures.dart';

/// The event propagated through the Flame engine when the user starts a drag
/// gesture on the game canvas.
///
/// This is a [PositionEvent], where the position is the point of touch.
class DragStartEvent(
  /// The unique identifier of the drag event.
  ///
  /// Subsequent [DragUpdateEvent] or [DragEndEvent] will carry the same pointer
  /// id. This allows distinguishing multiple drags that may occur at the same
  /// time on the same component.
  final int pointerId,
  super.game,
  DragStartDetails details,
) extends PositionEvent<DragStartDetails> {
  this
    : super(
        raw: details,
        devicePosition: details.globalPosition.toVector2(),
      );

  final PointerDeviceKind deviceKind =
      details.kind ?? PointerDeviceKind.unknown;

  @override
  String toString() =>
      'DragStartEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'pointedId: $pointerId, deviceKind: $deviceKind)';
}
