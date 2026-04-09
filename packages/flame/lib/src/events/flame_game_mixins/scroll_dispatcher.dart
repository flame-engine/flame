import 'package:flame/components.dart';
import 'package:flame/src/events/component_mixins/scroll_callbacks.dart';
import 'package:flame/src/events/messages/scroll_event.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flutter/gestures.dart' as flutter;
import 'package:meta/meta.dart';

/// **ScrollDispatcher** facilitates dispatching of pointer scroll events to the
/// [ScrollCallbacks] components in the component tree. It will be attached
/// to the [FlameGame] instance automatically whenever any
/// [ScrollCallbacks] components are mounted into the component tree.
class ScrollDispatcher extends Component {
  FlameGame get game => parent! as FlameGame;

  @mustCallSuper
  void onPointerScroll(ScrollEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      deliverToAll: true,
      eventHandler: (ScrollCallbacks component) {
        component.onScroll(event);
      },
    );
  }

  void _handlePointerScroll(flutter.PointerScrollEvent event) {
    onPointerScroll(ScrollEvent.fromPointerScrollEvent(game, event));
  }

  @override
  void onMount() {
    game.scrollDetector = _handlePointerScroll;
  }

  @override
  void onRemove() {
    game.scrollDetector = null;
    game.unregisterKey(const ScrollDispatcherKey());
  }
}

/// Unique key for the [ScrollDispatcher] so the game can identify it.
class ScrollDispatcherKey implements ComponentKey {
  const ScrollDispatcherKey();

  @override
  int get hashCode => 'ScrollDispatcherKey'.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ScrollDispatcherKey && other.hashCode == hashCode;
}
