import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import '../base_component.dart';
import '../component.dart';
import '../../extensions/offset.dart';
import '../../game/base_game.dart';

mixin Tapable on BaseComponent {
  bool onTapCancel() {
    return true;
  }

  bool onTapDown(TapDownDetails details) {
    return true;
  }

  bool onTapUp(TapUpDetails details) {
    return true;
  }

  int? _currentPointerId;

  bool _checkPointerId(int pointerId) => _currentPointerId == pointerId;

  bool handleTapDown(int pointerId, TapDownDetails details) {
    if (containsPoint(details.localPosition.toVector2())) {
      _currentPointerId = pointerId;
      return onTapDown(details);
    }
    return true;
  }

  bool handleTapUp(int pointerId, TapUpDetails details) {
    if (_checkPointerId(pointerId) &&
        containsPoint(details.localPosition.toVector2())) {
      _currentPointerId = null;
      return onTapUp(details);
    }
    return true;
  }

  bool handleTapCancel(int pointerId) {
    if (_checkPointerId(pointerId)) {
      _currentPointerId = null;
      return onTapCancel();
    }
    return true;
  }
}

mixin HasTapableComponents on BaseGame {
  void _handleTapEvent(bool Function(Tapable child) tapEventHandler) {
    for (Component c in components.toList().reversed) {
      bool shouldContinue = true;
      if (c is BaseComponent) {
        shouldContinue = c.propagateToChildren<Tapable>(tapEventHandler);
      }
      if (c is Tapable && shouldContinue) {
        shouldContinue = tapEventHandler(c);
      }
      if (!shouldContinue) {
        break;
      }
    }
  }

  @mustCallSuper
  void onTapCancel(int pointerId) {
    _handleTapEvent((Tapable child) => child.handleTapCancel(pointerId));
  }

  @mustCallSuper
  void onTapDown(int pointerId, TapDownDetails details) {
    _handleTapEvent((Tapable child) => child.handleTapDown(pointerId, details));
  }

  @mustCallSuper
  void onTapUp(int pointerId, TapUpDetails details) {
    _handleTapEvent((Tapable child) => child.handleTapUp(pointerId, details));
  }
}
