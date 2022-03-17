import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../game.dart';
import '../../gestures/events.dart';

mixin HasTappables on FlameGame {
  @mustCallSuper
  bool onTapCancel(int pointerId) {
    return propagateToChildren(
      (Tappable child) => child.handleTapCancel(pointerId),
    );
  }

  @mustCallSuper
  bool onTapDown(int pointerId, TapDownInfo info) {
    return propagateToChildren(
      (Tappable child) => child.handleTapDown(pointerId, info),
    );
  }

  @mustCallSuper
  bool onTapUp(int pointerId, TapUpInfo info) {
    return propagateToChildren(
      (Tappable child) => child.handleTapUp(pointerId, info),
    );
  }
}
