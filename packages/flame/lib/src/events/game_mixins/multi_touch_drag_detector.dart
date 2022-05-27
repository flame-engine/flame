import 'package:flame/src/events/interfaces/multi_drag_listener.dart';
import 'package:flame/src/game/mixins/game.dart';
import 'package:flame/src/game/mixins/has_draggables.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/gestures.dart';

/// Mixin that can be added to a [Game] allowing it to receive drag events.
///
/// The user can override one of the callback methods
///  - [onDragStart]
///  - [onDragUpdate]
///  - [onDragEnd]
///  - [onDragCancel]
/// in order to respond to each corresponding event. Those events whose methods
/// are not overridden are ignored.
///
/// See [MultiDragGestureRecognizer] for the description of each individual
/// event. If your game is derived from the FlameGame class, consider using the
/// [HasDraggables] mixin instead.
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
