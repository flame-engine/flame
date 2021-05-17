import 'package:meta/meta.dart';

import '../../../game.dart';
import '../../game/base_game.dart';
import '../../gestures/events.dart';
import '../base_component.dart';

mixin Hoverable on BaseComponent {
  bool isHovered = false;
  void onEnter(PointerHoverInfo event) {}
  void onLeave(PointerHoverInfo event) {}
}

mixin HasHoverableComponents on BaseGame {
  @mustCallSuper
  void onMouseMove(PointerHoverInfo event) {
    final p = event.eventPosition.game;
    bool _mouseMoveHandler(Hoverable c) {
      if (c.containsPoint(p)) {
        if (!c.isHovered) {
          c.isHovered = true;
          c.onEnter(event);
        }
      } else {
        if (c.isHovered) {
          c.isHovered = false;
          c.onLeave(event);
        }
      }
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
