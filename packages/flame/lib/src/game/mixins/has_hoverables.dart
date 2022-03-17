import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../game.dart';
import '../../gestures/events.dart';

mixin HasHoverables on FlameGame {
  @mustCallSuper
  bool onMouseMove(PointerHoverInfo info) {
    return propagateToChildren<Hoverable>((c) => c.handleMouseMovement(info));
  }
}
