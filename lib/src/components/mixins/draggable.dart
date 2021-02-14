import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../extensions.dart';
import '../../game/base_game.dart';
import '../base_component.dart';
import '../component.dart';

mixin Draggable on BaseComponent {
  bool onDragStarted(int pointerId, Vector2 startPosition) {
    return true;
  }

  bool onDragUpdated(int pointerId, DragUpdateDetails details) {
    return true;
  }

  bool onDragEnded(int pointerId, DragEndDetails details) {
    return true;
  }

  bool onDragCanceled(int pointerId) {
    return true;
  }

  final List<int> _currentPointerIds = [];
  bool _checkPointerId(int pointerId) => _currentPointerIds.contains(pointerId);

  bool handleDragStart(int pointerId, Vector2 startPosition) {
    if (containsPoint(startPosition)) {
      _currentPointerIds.add(pointerId);
      return onDragStarted(pointerId, startPosition);
    }
    return true;
  }

  bool handleDragUpdated(int pointerId, DragUpdateDetails details) {
    if (_checkPointerId(pointerId)) {
      return onDragUpdated(pointerId, details);
    }
    return true;
  }

  bool handleDragEnded(int pointerId, DragEndDetails details) {
    if (_checkPointerId(pointerId)) {
      _currentPointerIds.remove(pointerId);
      return onDragEnded(pointerId, details);
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
  void onDragStarted(int pointerId, Vector2 startPosition) {
    _onGenericEventReceived((c) => c.handleDragStart(pointerId, startPosition));
  }

  @mustCallSuper
  void onDragUpdated(int pointerId, DragUpdateDetails details) {
    _onGenericEventReceived((c) => c.handleDragUpdated(pointerId, details));
  }

  @mustCallSuper
  void onDragEnded(int pointerId, DragEndDetails details) {
    _onGenericEventReceived((c) => c.handleDragEnded(pointerId, details));
  }

  @mustCallSuper
  void onDragCanceled(int pointerId) {
    _onGenericEventReceived((c) => c.handleDragCanceled(pointerId));
  }

  void _onGenericEventReceived(bool Function(Draggable) handler) {
    for (Component c in components.toList().reversed) {
      bool shouldContinue = true;
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
