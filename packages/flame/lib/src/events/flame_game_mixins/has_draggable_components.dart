import 'package:flame/src/events/component_mixins/drag_callbacks.dart';
import 'package:flame/src/events/interfaces/multi_drag_listener.dart';
import 'package:flame/src/events/messages/drag_cancel_event.dart';
import 'package:flame/src/events/messages/drag_end_event.dart';
import 'package:flame/src/events/messages/drag_start_event.dart';
import 'package:flame/src/events/messages/drag_update_event.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

mixin HasDraggableComponents on FlameGame implements MultiDragListener {
  @mustCallSuper
  void onDragStart(DragStartEvent event) {
    event.deliverAtPoint(
      rootComponent: this,
      eventHandler: (DragCallbacks component) {
        component.onDragStart(event);
      },
    );
  }

  @mustCallSuper
  void onDragUpdate(DragUpdateEvent event) {}

  @mustCallSuper
  void onDragEnd(DragEndEvent event) {}

  @mustCallSuper
  void onDragCancel(DragCancelEvent event) {}

  //#region MultiDragListener API

  @internal
  @override
  void handleDragStart(int pointerId, DragStartDetails details) {
    onDragStart(DragStartEvent(pointerId, details));
  }

  @internal
  @override
  void handleDragUpdate(int pointerId, DragUpdateDetails details) {
    onDragUpdate(DragUpdateEvent(pointerId, details));
  }

  @internal
  @override
  void handleDragEnd(int pointerId, DragEndDetails details) {
    onDragEnd(DragEndEvent(pointerId, details));
  }

  @internal
  @override
  void handleDragCancel(int pointerId) {
    onDragCancel(DragCancelEvent(pointerId));
  }

  //#endregion
}
