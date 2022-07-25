import 'package:flame/components.dart';
import 'package:flame/src/gestures/events.dart';

mixin CursorHandler on Component {
  bool onMouseMove(PointerHoverInfo info) {
    return true;
  }
}
