import 'package:flame/src/events/messages/drag_end_event.dart';
import 'package:flame/src/events/messages/drag_start_event.dart';
import 'package:flame/src/events/messages/event.dart';
import 'package:flutter/gestures.dart';
import 'package:vector_math/vector_math_64.dart';

class DragCancelEvent extends Event {
  DragCancelEvent(this.pointerId);

  /// The id of the event that has been cancelled. This id corresponds to the
  /// id of the previous [DragStartEvent].
  final int pointerId;

  DragEndEvent toDragEnd() {
    return DragEndEvent(
      pointerId,
      DragEndDetails(),
      devicePosition: Vector2.zero(),
      canvasPosition: Vector2.zero(),
    );
  }
}
