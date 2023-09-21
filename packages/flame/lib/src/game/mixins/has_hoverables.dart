import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:meta/meta.dart';

@Deprecated(
  'Will be removed in Flame v1.10.0, use HoverCallbacks without a game mixin '
  'instead.',
)
mixin HasHoverables on FlameGame {
  @mustCallSuper
  void onMouseMove(PointerHoverInfo info) {
    propagateToChildren<Hoverable>((c) => c.handleMouseMovement(info));
  }
}
