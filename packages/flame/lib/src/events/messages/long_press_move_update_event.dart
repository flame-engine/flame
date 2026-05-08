import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/displacement_event.dart';
import 'package:flutter/gestures.dart';

/// The event propagated through the Flame engine when the user moves their
/// pointer during an active long press gesture.
///
/// This is a [DisplacementEvent] whose start/end positions represent a
/// frame-to-frame delta, matching the semantics of `DragUpdateEvent`.
/// Use [localDelta] to move a component to follow the pointer.
class LongPressMoveUpdateEvent
    extends DisplacementEvent<LongPressMoveUpdateDetails> {
  /// Creates a [LongPressMoveUpdateEvent].
  ///
  /// [previousGlobalPosition] is the global position from the previous
  /// move-update (or the start position for the first update). This is used
  /// to compute the frame-to-frame delta.
  LongPressMoveUpdateEvent(
    this.pointerId,
    super.game,
    LongPressMoveUpdateDetails details, {
    required Offset previousGlobalPosition,
  }) : offsetFromOrigin = details.offsetFromOrigin.toVector2(),
       super(
         raw: details,
         deviceStartPosition: previousGlobalPosition.toVector2(),
         deviceEndPosition: details.globalPosition.toVector2(),
       );

  /// The unique identifier for this long press gesture.
  final int pointerId;

  /// The offset from the initial long press contact point.
  final Vector2 offsetFromOrigin;

  @override
  String toString() =>
      'LongPressMoveUpdateEvent(canvasEndPosition: $canvasEndPosition, '
      'delta: $localDelta, '
      'pointerId: $pointerId)';
}
