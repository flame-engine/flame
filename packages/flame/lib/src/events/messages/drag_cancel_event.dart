import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';

class DragCancelEvent(
  /// The id of the event that has been cancelled. This id corresponds to the
  /// id of the previous [DragStartEvent].
  final int pointerId,
) extends Event<void> {
  this : super(raw: null);

  DragEndEvent toDragEnd() => DragEndEvent(pointerId, DragEndDetails());

  @override
  String toString() => 'DragCancelEvent(pointerId: $pointerId)';
}
