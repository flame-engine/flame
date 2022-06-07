
import 'package:flame/src/components/component.dart';
import 'package:flame/src/events/messages/drag_start_event.dart';

mixin DragCallbacks on Component {
  void onDragStart(DragStartEvent event);
}
