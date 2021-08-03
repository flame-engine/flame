import 'package:meta/meta.dart';

import '../../../game.dart';
import '../../game/base_game.dart';
import '../../gestures/events.dart';
import '../base_component.dart';

mixin Tappable on BaseComponent {
  bool onTapCancel() {
    return true;
  }

  bool onTapDown(TapDownInfo info) {
    return true;
  }

  bool onTapUp(TapUpInfo info) {
    return true;
  }

  int? _currentPointerId;

  bool _checkPointerId(int pointerId) => _currentPointerId == pointerId;

  bool handleTapDown(int pointerId, TapDownInfo info) {
    if (containsPoint(eventPosition(info))) {
      _currentPointerId = pointerId;
      return onTapDown(info);
    }
    return true;
  }

  bool handleTapUp(int pointerId, TapUpInfo info) {
    if (_checkPointerId(pointerId) && containsPoint(eventPosition(info))) {
      _currentPointerId = null;
      return onTapUp(info);
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

mixin HasTappableComponents on BaseGame {
  void _handleTapEvent(bool Function(Tappable child) tapEventHandler) {
    for (final c in components.reversed()) {
      var shouldContinue = true;
      if (c is BaseComponent) {
        shouldContinue = c.propagateToChildren<Tappable>(tapEventHandler);
      }
      if (c is Tappable && shouldContinue) {
        shouldContinue = tapEventHandler(c);
      }
      if (!shouldContinue) {
        break;
      }
    }
  }

  @mustCallSuper
  void onTapCancel(int pointerId) {
    _handleTapEvent((Tappable child) => child.handleTapCancel(pointerId));
  }

  @mustCallSuper
  void onTapDown(int pointerId, TapDownInfo info) {
    _handleTapEvent((Tappable child) => child.handleTapDown(pointerId, info));
  }

  @mustCallSuper
  void onTapUp(int pointerId, TapUpInfo info) {
    _handleTapEvent((Tappable child) => child.handleTapUp(pointerId, info));
  }
}
