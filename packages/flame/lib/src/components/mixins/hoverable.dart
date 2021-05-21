import 'package:meta/meta.dart';

import '../../../game.dart';
import '../../game/base_game.dart';
import '../../gestures/events.dart';
import '../base_component.dart';

mixin Hoverable on BaseComponent {
  bool _isHovered = false;
  bool get isHovered => _isHovered;
  void onHoverEnter(PointerHoverInfo event) {}
  void onHoverLeave(PointerHoverInfo event) {}

  @nonVirtual
  void doHandleMouseMovement(PointerHoverInfo event, Vector2 p) {
    if (containsPoint(p)) {
      if (!_isHovered) {
        _isHovered = true;
        onHoverEnter(event);
      }
    } else {
      if (_isHovered) {
        _isHovered = false;
        onHoverLeave(event);
      }
    }
  }
}

mixin HasHoverableComponents on BaseGame {
  @mustCallSuper
  void onMouseMove(PointerHoverInfo event) {
    final p = event.eventPosition.game;
    bool _mouseMoveHandler(Hoverable c) {
      c.doHandleMouseMovement(event, p);
      return true; // always continue
    }

    for (final c in components.toList().reversed) {
      if (c is BaseComponent) {
        c.propagateToChildren<Hoverable>(_mouseMoveHandler);
      }
      if (c is Hoverable) {
        _mouseMoveHandler(c);
      }
    }
  }
}
