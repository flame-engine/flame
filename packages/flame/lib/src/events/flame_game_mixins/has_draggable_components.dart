import 'package:flame/src/events/component_mixins/drag_callbacks.dart';
import 'package:flame/src/events/interfaces/multi_drag_listener.dart';
import 'package:flame/src/events/messages/drag_cancel_event.dart';
import 'package:flame/src/events/messages/drag_end_event.dart';
import 'package:flame/src/events/messages/drag_start_event.dart';
import 'package:flame/src/events/messages/drag_update_event.dart';
import 'package:flame/src/events/tagged_component.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

mixin HasDraggableComponents on FlameGame implements MultiDragListener {
  /// The record of all components currently being touched.
  final Set<TaggedComponent<DragCallbacks>> _records = {};

  @mustCallSuper
  void onDragStart(DragStartEvent event) {
    event.deliverAtPoint(
      rootComponent: this,
      eventHandler: (DragCallbacks component) {
        _records.add(TaggedComponent(event.pointerId, component));
        component.onDragStart(event);
      },
    );
  }

  @mustCallSuper
  void onDragUpdate(DragUpdateEvent event) {
    final updated = <TaggedComponent<DragCallbacks>>{};
    event.deliverAtPoint(
      rootComponent: this,
      eventHandler: (DragCallbacks component) {
        final record = TaggedComponent(event.pointerId, component);
        if (_records.contains(record)) {
          component.onDragUpdate(event);
          updated.add(record);
        }
      },
    );
    event.renderingTrace.add(Vector2(double.nan, double.nan));
    for (final record in _records) {
      if (record.pointerId == event.pointerId && !updated.contains(record)) {
        record.component.onDragUpdate(event);
      }
    }
    event.renderingTrace.removeLast();
  }

  @mustCallSuper
  void onDragEnd(DragEndEvent event) {
    _records.removeWhere((record) {
      if (record.pointerId == event.pointerId) {
        record.component.onDragEnd(event);
        return true;
      }
      return false;
    });
  }

  @mustCallSuper
  void onDragCancel(DragCancelEvent event) {
    _records.removeWhere((record) {
      if (record.pointerId == event.pointerId) {
        record.component.onDragCancel(event);
        return true;
      }
      return false;
    });
  }

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
