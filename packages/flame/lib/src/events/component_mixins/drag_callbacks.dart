import 'package:flame/src/components/component.dart';
import 'package:flame/src/events/flame_game_mixins/has_draggable_components.dart';
import 'package:flame/src/events/messages/drag_cancel_event.dart';
import 'package:flame/src/events/messages/drag_end_event.dart';
import 'package:flame/src/events/messages/drag_start_event.dart';
import 'package:flame/src/events/messages/drag_update_event.dart';

mixin DragCallbacks on Component {
  void onDragStart(DragStartEvent event) {}
  void onDragUpdate(DragUpdateEvent event) {}
  void onDragEnd(DragEndEvent event) {}
  void onDragCancel(DragCancelEvent event) {}

  @override
  void onMount() {
    super.onMount();
    assert(
      findGame()! is HasDraggableComponents,
      'The components with DragCallbacks can only be added to a FlameGame with '
      'the HasDraggableComponents mixin',
    );
  }
}
