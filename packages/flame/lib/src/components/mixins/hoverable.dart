import 'package:meta/meta.dart';

import '../../../game.dart';
import '../../game/base_game.dart';
import '../../gestures/events.dart';
import '../base_component.dart';

mixin Hoverable on BaseComponent {
  bool _isHovered = false;
  bool get isHovered => _isHovered;
  void onHoverEnter(PointerHoverInfo info) {}
  void onHoverLeave(PointerHoverInfo info) {}

  @nonVirtual
  void handleMouseMovement(PointerHoverInfo info) {
    if (containsPoint(eventPosition(info))) {
      if (!_isHovered) {
        _isHovered = true;
        onHoverEnter(info);
      }
    } else {
      if (_isHovered) {
        _isHovered = false;
        onHoverLeave(info);
      }
    }
  }
}

mixin HasHoverableComponents on BaseGame {
  @mustCallSuper
  void onMouseMove(PointerHoverInfo info) {
    bool _mouseMoveHandler(Hoverable c) {
      c.handleMouseMovement(info);
      return true; // always continue
    }

    for (final c in components.reversed()) {
      if (c is BaseComponent) {
        c.propagateToChildren<Hoverable>(_mouseMoveHandler);
      }
      if (c is Hoverable) {
        _mouseMoveHandler(c);
      }
    }
  }
}
