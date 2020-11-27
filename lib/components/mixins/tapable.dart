import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import '../base_component.dart';
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

  int _currentPointerId;

  bool _checkPointerId(int pointerId) => _currentPointerId == pointerId;

  bool handleTapDown(int pointerId, TapDownDetails details) {
    if (checkOverlap(details.localPosition.toVector2())) {
      _currentPointerId = pointerId;
      return onTapDown(details);
    }
    return true;
  }

  bool handleTapUp(int pointerId, TapUpDetails details) {
    if (_checkPointerId(pointerId) &&
        checkOverlap(details.localPosition.toVector2())) {
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
  @mustCallSuper
  void onTapCancel(int pointerId) {
    components.forEach((c) {
      if (c is BaseComponent) {
        c.propagateToChildren<Tapable>(
          (child) => child.handleTapCancel(pointerId),
        );
      }
    });
  }

  @mustCallSuper
  void onTapDown(int pointerId, TapDownDetails details) {
    components.forEach((c) {
      if (c is BaseComponent) {
        c.propagateToChildren<Tapable>(
          (child) => child.handleTapDown(pointerId, details),
        );
      }
    });
  }

  @mustCallSuper
  void onTapUp(int pointerId, TapUpDetails details) {
    components.forEach((c) {
      if (c is BaseComponent) {
        c.propagateToChildren<Tapable>(
          (child) => child.handleTapUp(pointerId, details),
        );
      }
    });
  }
}
