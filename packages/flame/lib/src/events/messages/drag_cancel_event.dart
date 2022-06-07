import 'package:flame/src/events/messages/drag_start_event.dart';
import 'package:flame/src/events/messages/event.dart';

class DragCancelEvent extends Event {
  DragCancelEvent(this.pointerId);

  /// The id of the event that has been cancelled. This id corresponds to the
  /// id of the previous [DragStartEvent].
  final int pointerId;
}
