import 'package:flame/events.dart';
import 'package:flame/src/events/flame_drag_adapter.dart';
import 'package:flame/src/game/game.dart';
import 'package:flutter/gestures.dart';

/// Mixin that can be added to a [Game] allowing it to receive drag events.
///
/// The user can override one of the callback methods
///  - [onDragStart]
///  - [onDragUpdate]
///  - [onDragEnd]
///  - [onDragCancel]
/// in order to respond to each corresponding event. Those events whose methods
/// are not overridden are ignored. See [MultiDragListener] for the description
/// of each individual event.
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
    onDragEnd(pointerId, DragEndInfo.fromDetails(details));
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
