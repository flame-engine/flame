import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../events/flame_game_mixins/has_tappables.dart';
import '../../gestures/events.dart';

mixin Tappable on Component {
  bool onTap() => true;

  bool onTapCancel() => true;

  bool onTapDown(TapDownInfo info) => true;

  bool onTapUp(TapUpInfo info) => true;

  bool onLongTapDown(TapDownInfo info) => true;

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

  bool handleLongTapDown(int pointerId, TapDownInfo info) {
    if (containsPoint(eventPosition(info))) {
      _currentPointerId = pointerId;
      return onLongTapDown(info);
    }
    return true;
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    assert(
      findGame()! is HasTappables,
      'Tappable Components can only be added to a FlameGame with '
      'HasTappables',
    );
  }
}
