import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../game.dart';
import '../../game/flame_game.dart';
import '../../gestures/events.dart';

mixin Hoverable on Component {
  bool _isHovered = false;
  bool get isHovered => _isHovered;
  bool onHoverEnter(PointerHoverInfo info) {
    return true;
  }

  bool onHoverLeave(PointerHoverInfo info) {
    return true;
  }

  @nonVirtual
  bool handleMouseMovement(PointerHoverInfo info) {
    if (containsPoint(eventPosition(info))) {
      if (!_isHovered) {
        _isHovered = true;
        return onHoverEnter(info);
      }
    } else {
      if (_isHovered) {
        _isHovered = false;
        return onHoverLeave(info);
      }
    }
    return true;
  }

  @override
  @mustCallSuper
  void prepare(Component component) {
    super.prepare(component);
    if (isPrepared) {
      final parentGame = findParent<FlameGame>();
      assert(
        parentGame is HasHoverableComponents,
        'Hoverable Components can only be added to a FlameGame with '
        'HasHoverableComponents',
      );
    }
  }
}

mixin HasHoverableComponents on FlameGame {
  @mustCallSuper
  void onMouseMove(PointerHoverInfo info) {
    bool _mouseMoveHandler(Hoverable c) {
      return c.handleMouseMovement(info);
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
