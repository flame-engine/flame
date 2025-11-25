import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';

class SecondaryTapDispatcherKey implements ComponentKey {
  const SecondaryTapDispatcherKey();

  @override
  int get hashCode => 'SecondaryTapDispatcherKey'.hashCode;

  @override
  bool operator ==(Object other) =>
      other is SecondaryTapDispatcherKey && other.hashCode == hashCode;
}

/// [SecondaryTapDispatcher] propagates secondary-tap events (i.e. right mouse
/// clicks) to every components in the component tree that is mixed with
/// [SecondaryTapCallbacks]. This will be attached to the [FlameGame] instance
/// automatically whenever any [SecondaryTapCallbacks] are mounted into the
/// component tree.
class SecondaryTapDispatcher extends Component
    with HasGameReference<FlameGame> {
  final _components = <SecondaryTapCallbacks>{};

  void _onSecondaryTapDown(SecondaryTapDownEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (SecondaryTapCallbacks component) {
        _components.add(component..onSecondaryTapDown(event));
      },
    );
  }

  void _onSecondaryTapUp(SecondaryTapUpEvent event) {
    for (final component in _components) {
      component.onSecondaryTapUp(event);
    }
    _components.clear();
  }

  void _onSecondaryTapCancel(SecondaryTapCancelEvent event) {
    for (final component in _components) {
      component.onSecondaryTapCancel(event);
    }
    _components.clear();
  }

  @override
  void onMount() {
    game.gestureDetectors.add(
      TapGestureRecognizer.new,
      (TapGestureRecognizer instance) {
        instance.onSecondaryTapDown = (details) =>
            _onSecondaryTapDown(SecondaryTapDownEvent(game, details));
        instance.onSecondaryTapCancel = () =>
            _onSecondaryTapCancel(SecondaryTapCancelEvent());
        instance.onSecondaryTapUp = (details) =>
            _onSecondaryTapUp(SecondaryTapUpEvent(game, details));
      },
    );
  }

  @override
  void onRemove() {
    game.gestureDetectors.remove<TapGestureRecognizer>();
    game.unregisterKey(const SecondaryTapDispatcherKey());
  }
}
