import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../extensions.dart';
import '../../game/base_game.dart';
import '../base_component.dart';

mixin Draggable on BaseComponent {
  bool onDragStart(int pointerId, Vector2 startPosition) {
    return true;
  }

  bool onDragUpdate(int pointerId, DragUpdateDetails details) {
    return true;
  }

  bool onDragEnd(int pointerId, DragEndDetails details) {
    return true;
  }

  bool onDragCancel(int pointerId) {
    return true;
  }

  final List<int> _currentPointerIds = [];
  bool _checkPointerId(int pointerId) => _currentPointerIds.contains(pointerId);

  bool handleDragStart(int pointerId, Vector2 startPosition) {
    if (containsPoint(startPosition)) {
      _currentPointerIds.add(pointerId);
      return onDragStart(pointerId, startPosition);
    }
    return true;
  }

  bool handleDragUpdated(int pointerId, DragUpdateDetails details) {
    if (_checkPointerId(pointerId)) {
      return onDragUpdate(pointerId, details);
    }
    return true;
  }

  bool handleDragEnded(int pointerId, DragEndDetails details) {
    if (_checkPointerId(pointerId)) {
      _currentPointerIds.remove(pointerId);
      return onDragEnd(pointerId, details);
    }
    return true;
  }

  bool handleDragCanceled(int pointerId) {
    if (_checkPointerId(pointerId)) {
      _currentPointerIds.remove(pointerId);
      return handleDragCanceled(pointerId);
    }
    return true;
  }
}

mixin HasDraggableComponents on BaseGame {
  @mustCallSuper
  void onDragStart(int pointerId, Vector2 startPosition) {
    _onGenericEventReceived((c) => c.handleDragStart(pointerId, startPosition));
  }

  @mustCallSuper
  void onDragUpdate(int pointerId, DragUpdateDetails details) {
    _onGenericEventReceived((c) => c.handleDragUpdated(pointerId, details));
  }

  @mustCallSuper
  void onDragEnd(int pointerId, DragEndDetails details) {
    _onGenericEventReceived((c) => c.handleDragEnded(pointerId, details));
  }

  @mustCallSuper
  void onDragCancel(int pointerId) {
    _onGenericEventReceived((c) => c.handleDragCanceled(pointerId));
  }

  void _onGenericEventReceived(bool Function(Draggable) handler) {
    for (final c in components.toList().reversed) {
      var shouldContinue = true;
      if (c is BaseComponent) {
        shouldContinue = c.propagateToChildren<Draggable>(handler);
      }
      if (c is Draggable && shouldContinue) {
        shouldContinue = handler(c);
      }
      if (!shouldContinue) {
        break;
      }
    }
  }
}
