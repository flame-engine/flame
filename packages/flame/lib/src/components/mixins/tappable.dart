import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../game.dart';
import '../../game/flame_game.dart';
import '../../gestures/events.dart';

mixin Tappable on Component {
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

  @override
  @mustCallSuper
  void prepare(Component component) {
    super.prepare(component);
    if (isPrepared) {
      final parentGame = findParent<FlameGame>();
      assert(
        parentGame is HasTappables,
        'Tappable Components can only be added to a FlameGame with '
        'HasTappables',
      );
    }
  }
}

// TODO(spydon): these methods should return the result of propagateToChildren.
mixin HasTappables on FlameGame {
  @mustCallSuper
  void onTapCancel(int pointerId) {
    propagateToChildren((Tappable child) => child.handleTapCancel(pointerId));
  }

  @mustCallSuper
  void onTapDown(int pointerId, TapDownInfo info) {
    propagateToChildren(
      (Tappable child) => child.handleTapDown(pointerId, info),
    );
  }

  @mustCallSuper
  void onTapUp(int pointerId, TapUpInfo info) {
    propagateToChildren((Tappable child) => child.handleTapUp(pointerId, info));
  }
}
