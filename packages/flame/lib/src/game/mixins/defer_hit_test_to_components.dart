import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:meta/meta.dart';

/// Makes the game transparent to pointer events wherever no component handles
/// them, and opaque otherwise, instead of reporting a hit across the board.
///
/// Combine this with `HitTestBehavior.deferToChild` on the [GameWidget] to let
/// events reach the widgets behind the game at every position that has no
/// interactive component (decided by a component tree walk at point of touch).
mixin DeferHitTestToComponents on FlameGame {
  @override
  bool containsEventHandlerAt(Vector2 position) {
    for (final component in componentsAtPoint(position)) {
      if (component is PointerInputCallbacks) {
        return true;
      }
    }
    return false;
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    assert(
      this is! PointerInputCallbacks,
      'A game that handles pointer events itself is interactive across its '
      'whole surface, so there is nothing for $DeferHitTestToComponents to '
      'defer. Move those callbacks to a component, or drop the mixin.',
    );
  }
}
