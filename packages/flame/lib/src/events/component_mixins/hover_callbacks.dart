import 'package:flame/game.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:meta/meta.dart';

/// This mixin can be added to a [Component] allowing it to receive hover events.
///
/// In addition to adding this mixin, the component must also implement the
/// [containsLocalPoint] method -- the component will only be considered
/// "hovered" if the point where the tap has occurred is inside the component.
///
/// This mixin is the replacement of the Hoverable mixin.
mixin HoverCallbacks on Component {
  void onHoverEnder() {}
  void onHoverExit() {}

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    final game = findGame()! as FlameGame;
    // TODO: bind dispatcher
  }
}
