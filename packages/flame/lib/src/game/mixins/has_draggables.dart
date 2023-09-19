import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/flame_drag_adapter.dart';
import 'package:flame/src/events/interfaces/multi_drag_listener.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

@Deprecated(
  'Will be removed in Flame v1.10.0, use DragCallbacks without a game mixin '
  'instead',
)
mixin HasDraggables on FlameGame implements MultiDragListener {
  @mustCallSuper
  void onDragStart(int pointerId, DragStartInfo info) {
    propagateToChildren<Draggable>(
      (c) => c.handleDragStart(pointerId, info),
    );
  }

  @mustCallSuper
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    propagateToChildren<Draggable>(
      (c) => c.handleDragUpdated(pointerId, info),
    );
  }

  @mustCallSuper
  void onDragEnd(int pointerId, DragEndInfo info) {
    propagateToChildren<Draggable>(
      (c) => c.handleDragEnded(pointerId, info),
    );
  }

  @mustCallSuper
  void onDragCancel(int pointerId) {
    propagateToChildren<Draggable>(
      (c) => c.handleDragCanceled(pointerId),
    );
  }

  //#region MultiDragListener API

  @override
  void handleDragStart(int pointerId, DragStartDetails details) {
    onDragStart(pointerId, DragStartInfo.fromDetails(this, details));
  }

  @override
  void handleDragUpdate(int pointerId, DragUpdateDetails details) {
    onDragUpdate(pointerId, DragUpdateInfo.fromDetails(this, details));
  }

  @override
  void handleDragEnd(int pointerId, DragEndDetails details) {
    onDragEnd(pointerId, DragEndInfo.fromDetails(this, details));
  }

  @override
  void handleDragCancel(int pointerId) {
    onDragCancel(pointerId);
  }

  //#endregion

  @override
  void mount() {
    gestureDetectors.add<ImmediateMultiDragGestureRecognizer>(
      ImmediateMultiDragGestureRecognizer.new,
      (ImmediateMultiDragGestureRecognizer instance) {
        instance.onStart = (Offset point) => FlameDragAdapter(this, point);
      },
    );
    super.mount();
  }
}
