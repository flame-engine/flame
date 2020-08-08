import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import '../../game/base_game.dart';
import '../position_component.dart';

mixin Tapable on PositionComponent {
  void onTapCancel() {}
  void onTapDown(TapDownDetails details) {}
  void onTapUp(TapUpDetails details) {}

  int _currentPointerId;

  bool _checkPointerId(int pointerId) => _currentPointerId == pointerId;

  bool checkTapOverlap(Rect rect, Offset o) => rect.contains(o);

  void handleTapDown(Rect rect, int pointerId, TapDownDetails details) {
    if (checkTapOverlap(rect, details.localPosition)) {
      _currentPointerId = pointerId;
      onTapDown(details);
    }
  }

  void handleTapUp(Rect rect, int pointerId, TapUpDetails details) {
    if (_checkPointerId(pointerId) &&
        checkTapOverlap(rect, details.localPosition)) {
      _currentPointerId = null;
      onTapUp(details);
    }
  }

  void handleTapCancel(int pointerId) {
    if (_checkPointerId(pointerId)) {
      _currentPointerId = null;
      onTapCancel();
    }
  }
}

mixin HasTapableComponents on BaseGame {
  Iterable<PositionComponent> _positionComponents() {
    return components.whereType<PositionComponent>();
  }

  @mustCallSuper
  void onTapCancel(int pointerId) {
    _positionComponents().forEach((c) {
      c.propagateToChildren<Tapable>(
        (child, _) => child.handleTapCancel(pointerId),
      );
    });
  }

  @mustCallSuper
  void onTapDown(int pointerId, TapDownDetails details) {
    _positionComponents().forEach((c) {
      c.propagateToChildren<Tapable>(
        (child, rect) => child.handleTapDown(rect, pointerId, details),
      );
    });
  }

  @mustCallSuper
  void onTapUp(int pointerId, TapUpDetails details) {
    _positionComponents().forEach((c) {
      c.propagateToChildren<Tapable>(
        (child, rect) => child.handleTapUp(rect, pointerId, details),
      );
    });
  }
}
