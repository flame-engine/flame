
import 'package:flame/src/events/interfaces/multi_drag_listener.dart';
import 'package:flame/src/events/messages/drag_start_event.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

mixin HasDraggableComponents on FlameGame implements MultiDragListener {
  @mustCallSuper
  void onDragStart(DragStartEvent event) {
  }

  @internal
  @override
  void handleDragStart(int pointerId, DragStartDetails details) {
    onDragStart(DragStartEvent(pointerId, details));
  }

  @internal
  @override
  void handleDragUpdate(int pointerId, DragUpdateDetails details);

  @internal
  @override
  void handleDragEnd(int pointerId, DragEndDetails details);

  @internal
  @override
  void handleDragCancel(int pointerId);
}
