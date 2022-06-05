import 'package:flame/components.dart';
import 'package:flame/src/game/mixins/has_draggables.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/material.dart';

mixin Draggable on Component {
  bool _isDragged = false;
  bool get isDragged => _isDragged;

  /// Override this to handle the start of a drag/pan gesture that is within the
  /// boundaries (determined by [Component.containsPoint]) of the component that
  /// this mixin is used on.
  /// Return `true` if you want this event to continue to be passed on to
  /// components underneath (lower priority) this component.
  bool onDragStart(DragStartInfo info) {
    return true;
  }

  /// Override this to handle the update of a drag/pan gesture that is within
  /// the boundaries (determined by [Component.containsPoint]) of the component
  /// that this mixin is used on.
  /// Return `true` if you want this event to continue to be passed on to
  /// components underneath (lower priority) this component.
  bool onDragUpdate(DragUpdateInfo info) {
    return true;
  }

  /// Override this to handle the end of a drag/pan gesture that is within
  /// the boundaries (determined by [Component.containsPoint]) of the component
  /// that this mixin is used on.
  /// Return `true` if you want this event to continue to be passed on to
  /// components underneath (lower priority) this component.
  bool onDragEnd(DragEndInfo info) {
    return true;
  }

  /// Override this to handle if a drag/pan gesture is cancelled that was
  /// previously started on the component that this mixin is used on.
  /// Return `true` if you want this event to continue to be passed on to
  /// components underneath (lower priority) this component.
  ///
  /// This event is not that common, it can happen for example when the user
  /// is interrupted by a system-modal dialog in the middle of the drag.
  bool onDragCancel() {
    return true;
  }

  final List<int> _currentPointerIds = [];
  bool _checkPointerId(int pointerId) => _currentPointerIds.contains(pointerId);

  bool handleDragStart(int pointerId, DragStartInfo info) {
    if (containsPoint(eventPosition(info))) {
      _isDragged = true;
      _currentPointerIds.add(pointerId);
      return onDragStart(info);
    }
    return true;
  }

  bool handleDragUpdated(int pointerId, DragUpdateInfo info) {
    if (_checkPointerId(pointerId)) {
      return onDragUpdate(info);
    }
    return true;
  }

  bool handleDragEnded(int pointerId, DragEndInfo info) {
    if (_checkPointerId(pointerId)) {
      _isDragged = false;
      _currentPointerIds.remove(pointerId);
      return onDragEnd(info);
    }
    return true;
  }

  bool handleDragCanceled(int pointerId) {
    if (_checkPointerId(pointerId)) {
      _isDragged = false;
      _currentPointerIds.remove(pointerId);
      return onDragCancel();
    }
    return true;
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    assert(
      findGame()! is HasDraggables,
      'Draggable Components can only be added to a FlameGame with '
      'HasDraggables',
    );
  }
}
