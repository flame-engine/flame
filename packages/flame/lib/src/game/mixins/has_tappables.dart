import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../game.dart';
import '../../gestures/events.dart';

mixin HasTappables on FlameGame {
  @mustCallSuper
  void onTapCancel(int pointerId) {
    propagateToChildren(
      (Tappable child) => child.handleTapCancel(pointerId),
    );
  }

  @mustCallSuper
  void onTapDown(int pointerId, TapDownInfo info) {
    propagateToChildren(
      (Tappable child) => child.handleTapDown(pointerId, info),
    );
  }

  @mustCallSuper
  void onTapUp(int pointerId, TapUpInfo info) {
    propagateToChildren(
      (Tappable child) => child.handleTapUp(pointerId, info),
    );
  }
}
