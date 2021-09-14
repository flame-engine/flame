import 'package:flutter/material.dart';

import '../../../components.dart';
import '../../game/flame_game.dart';
import '../../gestures/events.dart';

mixin Draggable on Component {
  bool _isDragged = false;
  bool get isDragged => _isDragged;

  bool onDragStart(int pointerId, DragStartInfo info) {
    return true;
  }

  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    return true;
  }

  bool onDragEnd(int pointerId, DragEndInfo info) {
    return true;
  }

  bool onDragCancel(int pointerId) {
    return true;
  }

  final List<int> _currentPointerIds = [];
  bool _checkPointerId(int pointerId) => _currentPointerIds.contains(pointerId);

  bool handleDragStart(int pointerId, DragStartInfo info) {
    if (containsPoint(eventPosition(info))) {
      _isDragged = true;
      _currentPointerIds.add(pointerId);
      return onDragStart(pointerId, info);
    }
    return true;
  }

  bool handleDragUpdated(int pointerId, DragUpdateInfo details) {
    if (_checkPointerId(pointerId)) {
      return onDragUpdate(pointerId, details);
    }
    return true;
  }

  bool handleDragEnded(int pointerId, DragEndInfo details) {
    if (_checkPointerId(pointerId)) {
      _isDragged = false;
      _currentPointerIds.remove(pointerId);
      return onDragEnd(pointerId, details);
    }
    return true;
  }

  bool handleDragCanceled(int pointerId) {
    if (_checkPointerId(pointerId)) {
      _isDragged = false;
      _currentPointerIds.remove(pointerId);
      return handleDragCanceled(pointerId);
    }
    return true;
  }
}

mixin HasDraggableComponents on FlameGame {
  @mustCallSuper
  void onDragStart(int pointerId, DragStartInfo info) {
    _onGenericEventReceived((c) => c.handleDragStart(pointerId, info));
  }

  @mustCallSuper
  void onDragUpdate(int pointerId, DragUpdateInfo details) {
    _onGenericEventReceived((c) => c.handleDragUpdated(pointerId, details));
  }

  @mustCallSuper
  void onDragEnd(int pointerId, DragEndInfo details) {
    _onGenericEventReceived((c) => c.handleDragEnded(pointerId, details));
  }

  @mustCallSuper
  void onDragCancel(int pointerId) {
    _onGenericEventReceived((c) => c.handleDragCanceled(pointerId));
  }

  void _onGenericEventReceived(bool Function(Draggable) handler) {
    for (final c in children.reversed()) {
      var shouldContinue = c.propagateToChildren<Draggable>(handler);
      if (c is Draggable && shouldContinue) {
        shouldContinue = handler(c);
      }
      if (!shouldContinue) {
        break;
      }
    }
  }
}
