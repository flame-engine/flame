
import 'package:flame/src/events/interfaces/multi_drag_listener.dart';
import 'package:flame/src/game/mixins/game.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/gestures.dart';

mixin MultiTouchDragDetector on Game implements MultiDragListener {
  void onDragStart(int pointerId, DragStartInfo info) {}
  void onDragUpdate(int pointerId, DragUpdateInfo info) {}
  void onDragEnd(int pointerId, DragEndInfo info) {}
  void onDragCancel(int pointerId) {}

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
}
