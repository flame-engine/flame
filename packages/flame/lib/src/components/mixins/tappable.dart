import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../game/mixins/has_tappables.dart';
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
  void onMount() {
    super.onMount();
    assert(
      findGame()! is HasTappables,
      'Tappable Components can only be added to a FlameGame with '
      'HasTappables',
    );
  }
}
