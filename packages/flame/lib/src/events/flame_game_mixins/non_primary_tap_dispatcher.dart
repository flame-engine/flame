import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/flame_game_mixins/dispatcher.dart';
import 'package:flutter/gestures.dart';

class NonPrimaryTapDispatcherKey implements ComponentKey {
  const NonPrimaryTapDispatcherKey();

  @override
  int get hashCode => 'NonPrimaryTapDispatcherKey'.hashCode;

  @override
  bool operator ==(Object other) =>
      other is NonPrimaryTapDispatcherKey && other.hashCode == hashCode;
}

/// [NonPrimaryTapDispatcher] propagates non-primary tap events (i.e.
/// secondary/right and tertiary/middle mouse clicks) to every component in the
/// component tree that is mixed with [SecondaryTapCallbacks] or
/// [TertiaryTapCallbacks]. This will be attached to the [FlameGame] instance
/// automatically whenever any of those callbacks are mounted into the
/// component tree.
class NonPrimaryTapDispatcher extends Dispatcher<FlameGame> {
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
      const NonPrimaryTapDispatcherKey(),
      NonPrimaryTapDispatcher.new,
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
    Dispatcher.removeDispatcher(game, const NonPrimaryTapDispatcherKey());
  }
}
