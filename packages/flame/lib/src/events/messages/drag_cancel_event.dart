import 'package:flame/src/events/messages/drag_end_event.dart';
import 'package:flame/src/events/messages/drag_start_event.dart';
import 'package:flame/src/events/messages/event.dart';
import 'package:flutter/gestures.dart';

class DragCancelEvent extends Event {
  DragCancelEvent(this.pointerId);

  /// The id of the event that has been cancelled. This id corresponds to the
  /// id of the previous [DragStartEvent].
  final int pointerId;

  DragEndEvent toDragEnd() => DragEndEvent(pointerId, DragEndDetails());

  @override
  String toString() => 'DragCancelEvent(pointerId: $pointerId)';
}
