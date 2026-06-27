import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart' as flutter;
import 'package:meta/meta.dart';

/// **ScrollDispatcher** facilitates dispatching of pointer scroll events to the
/// [ScrollCallbacks] components in the component tree. It will be attached
/// to the [FlameGame] instance automatically whenever any
/// [ScrollCallbacks] components are mounted into the component tree.
class ScrollDispatcher extends Dispatcher<FlameGame> {
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

  static void addDispatcher(Component component) {
    Dispatcher.addDispatcher(
      component,
      const ScrollDispatcherKey(),
      ScrollDispatcher.new,
    );
  }

  @override
  void onMount() {
    game.scrollDetector = _handlePointerScroll;
  }

  @override
  void onRemove() {
    game.scrollDetector = null;
    Dispatcher.removeDispatcher(game, const ScrollDispatcherKey());
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
