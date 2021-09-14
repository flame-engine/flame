import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../game.dart';
import '../../game/flame_game.dart';
import '../../gestures/events.dart';

mixin Hoverable on Component {
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

mixin HasHoverableComponents on FlameGame {
  @mustCallSuper
  void onMouseMove(PointerHoverInfo info) {
    bool _mouseMoveHandler(Hoverable c) {
      c.handleMouseMovement(info);
      return true; // always continue
    }

    for (final c in children.reversed()) {
      var shouldContinue = c.propagateToChildren<Hoverable>(_mouseMoveHandler);
      if (c is Hoverable && shouldContinue) {
        shouldContinue = _mouseMoveHandler(c);
      }
      if (!shouldContinue) {
        break;
      }
    }
  }
}
