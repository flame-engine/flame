import 'package:flutter/material.dart';

import '../../../components.dart';
import '../../game/flame_game.dart';
import '../../gestures/events.dart';

mixin Draggable on Component {
  bool _isDragged = false;
  bool get isDragged => _isDragged;

  bool onDragStart(DragStartInfo info) {
    return true;
  }

  bool onDragUpdate(DragUpdateInfo info) {
    return true;
  }

  bool onDragEnd(DragEndInfo info) {
    return true;
  }

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
  void prepare(Component component) {
    super.prepare(component);
    if (isPrepared) {
      final parentGame = findParent<FlameGame>();
      assert(
        parentGame is HasDraggables,
        'Draggable Components can only be added to a FlameGame with '
        'HasDraggables',
      );
    }
  }
}

mixin HasDraggables on FlameGame {
  @mustCallSuper
  void onDragStart(int pointerId, DragStartInfo info) {
    propagateToChildren<Draggable>((c) => c.handleDragStart(pointerId, info));
  }

  @mustCallSuper
  void onDragUpdate(int pointerId, DragUpdateInfo details) {
    propagateToChildren<Draggable>(
      (c) => c.handleDragUpdated(pointerId, details),
    );
  }

  @mustCallSuper
  void onDragEnd(int pointerId, DragEndInfo details) {
    propagateToChildren<Draggable>(
      (c) => c.handleDragEnded(pointerId, details),
    );
  }

  @mustCallSuper
  void onDragCancel(int pointerId) {
    propagateToChildren<Draggable>((c) => c.handleDragCanceled(pointerId));
  }
}
