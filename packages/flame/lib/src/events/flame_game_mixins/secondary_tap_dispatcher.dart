import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/flame_game_mixins/dispatcher.dart';
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
class SecondaryTapDispatcher extends Dispatcher<FlameGame> {
  final _secondaryComponents = <SecondaryTapCallbacks>{};
  final _tertiaryComponents = <TertiaryTapCallbacks>{};

  void _onSecondaryTapDown(SecondaryTapDownEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (SecondaryTapCallbacks component) {
        _secondaryComponents.add(component..onSecondaryTapDown(event));
      },
    );
  }

  void _onSecondaryTapUp(SecondaryTapUpEvent event) {
    for (final component in _secondaryComponents) {
      component.onSecondaryTapUp(event);
    }
    _secondaryComponents.clear();
  }

  void _onSecondaryTapCancel(SecondaryTapCancelEvent event) {
    for (final component in _secondaryComponents) {
      component.onSecondaryTapCancel(event);
    }
    _secondaryComponents.clear();
  }

  void _onTertiaryTapDown(TertiaryTapDownEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (TertiaryTapCallbacks component) {
        _tertiaryComponents.add(component..onTertiaryTapDown(event));
      },
    );
  }

  void _onTertiaryTapUp(TertiaryTapUpEvent event) {
    for (final component in _tertiaryComponents) {
      component.onTertiaryTapUp(event);
    }
    _tertiaryComponents.clear();
  }

  void _onTertiaryTapCancel(TertiaryTapCancelEvent event) {
    for (final component in _tertiaryComponents) {
      component.onTertiaryTapCancel(event);
    }
    _tertiaryComponents.clear();
  }

  static void addDispatcher(Component component) {
    Dispatcher.addDispatcher(
      component,
      const SecondaryTapDispatcherKey(),
      SecondaryTapDispatcher.new,
    );
  }

  @override
  void onMount() {
    game.gestureDetectors.register(
      TapGestureRecognizer.new,
      (TapGestureRecognizer instance) {
        instance.onSecondaryTapDown = (details) =>
            _onSecondaryTapDown(SecondaryTapDownEvent(game, details));
        instance.onSecondaryTapCancel = () =>
            _onSecondaryTapCancel(SecondaryTapCancelEvent());
        instance.onSecondaryTapUp = (details) =>
            _onSecondaryTapUp(SecondaryTapUpEvent(game, details));
        instance.onTertiaryTapDown = (details) =>
            _onTertiaryTapDown(TertiaryTapDownEvent(game, details));
        instance.onTertiaryTapCancel = () =>
            _onTertiaryTapCancel(TertiaryTapCancelEvent());
        instance.onTertiaryTapUp = (details) =>
            _onTertiaryTapUp(TertiaryTapUpEvent(game, details));
      },
    );
  }

  @override
  void onRemove() {
    game.gestureDetectors.unregister<TapGestureRecognizer>();
    Dispatcher.removeDispatcher(game, const SecondaryTapDispatcherKey());
  }
}
