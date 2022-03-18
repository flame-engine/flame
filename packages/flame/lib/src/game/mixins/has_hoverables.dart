import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../game.dart';
import '../../gestures/events.dart';

mixin HasHoverables on FlameGame {
  @mustCallSuper
  void onMouseMove(PointerHoverInfo info) {
    propagateToChildren<Hoverable>((c) => c.handleMouseMovement(info));
  }
}
