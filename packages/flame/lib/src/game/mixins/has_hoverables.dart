import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:meta/meta.dart';

mixin HasHoverables on FlameGame {
  @mustCallSuper
  void onMouseMove(PointerHoverInfo info) {
    propagateToChildren<Hoverable>((c) => c.handleMouseMovement(info));
  }
}
