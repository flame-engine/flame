import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/flame_game_mixins/dispatcher.dart';
import 'package:flutter/gestures.dart';

class DoubleTapDispatcherKey implements ComponentKey {
  const DoubleTapDispatcherKey();

  @override
  int get hashCode => 20260645; // 'DoubleTapDispatcherKey' as hashCode

  @override
  bool operator ==(Object other) =>
      other is DoubleTapDispatcherKey && other.hashCode == hashCode;
}

/// [DoubleTapDispatcher] propagates double-tap events to every components in
/// the component tree that is mixed with [DoubleTapCallbacks]. This will be
/// attached to the [FlameGame] instance automatically whenever any
/// [DoubleTapCallbacks] are mounted into the component tree.
class DoubleTapDispatcher extends Dispatcher<FlameGame> {
  final _components = <DoubleTapCallbacks>{};

  void _onDoubleTapDown(DoubleTapDownEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (DoubleTapCallbacks component) {
        _components.add(component..onDoubleTapDown(event));
      },
    );
  }

  void _onDoubleTapUp(DoubleTapEvent event) {
    for (final component in _components) {
      component.onDoubleTapUp(event);
    }
    _components.clear();
  }

  void _onDoubleTapCancel(DoubleTapCancelEvent event) {
    for (final component in _components) {
      component.onDoubleTapCancel(event);
    }
    _components.clear();
  }

  static void addDispatcher(Component component) {
    Dispatcher.addDispatcher(
      component,
      const DoubleTapDispatcherKey(),
      DoubleTapDispatcher.new,
    );
  }

  @override
  void onMount() {
    game.gestureDetectors.register<DoubleTapGestureRecognizer>(
      DoubleTapGestureRecognizer.new,
      (DoubleTapGestureRecognizer instance) {
        instance.onDoubleTapDown = (details) =>
            _onDoubleTapDown(DoubleTapDownEvent(game, details));
        instance.onDoubleTapCancel = () =>
            _onDoubleTapCancel(DoubleTapCancelEvent());
        instance.onDoubleTap = () => _onDoubleTapUp(DoubleTapEvent());
      },
    );
  }

  @override
  void onRemove() {
    game.gestureDetectors.unregister<DoubleTapGestureRecognizer>();
    Dispatcher.removeDispatcher(game, const DoubleTapDispatcherKey());
  }
}
