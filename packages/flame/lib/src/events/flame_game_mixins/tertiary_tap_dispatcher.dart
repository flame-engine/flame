import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';

class TertiaryTapDispatcherKey implements ComponentKey {
  const TertiaryTapDispatcherKey();

  @override
  int get hashCode => 'TertiaryTapDispatcherKey'.hashCode;

  @override
  bool operator ==(Object other) =>
      other is TertiaryTapDispatcherKey && other.hashCode == hashCode;
}

/// [TertiaryTapDispatcher] propagates tertiary-tap events (i.e. middle mouse
/// clicks) to every component in the component tree that is mixed with
/// [TertiaryTapCallbacks]. This will be attached to the [FlameGame] instance
/// automatically whenever any [TertiaryTapCallbacks] are mounted into the
/// component tree.
class TertiaryTapDispatcher extends Component with HasGameReference<FlameGame> {
  final _components = <TertiaryTapCallbacks>{};

  void _onTertiaryTapDown(TertiaryTapDownEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (TertiaryTapCallbacks component) {
        _components.add(component..onTertiaryTapDown(event));
      },
    );
  }

  void _onTertiaryTapUp(TertiaryTapUpEvent event) {
    for (final component in _components) {
      component.onTertiaryTapUp(event);
    }
    _components.clear();
  }

  void _onTertiaryTapCancel(TertiaryTapCancelEvent event) {
    for (final component in _components) {
      component.onTertiaryTapCancel(event);
    }
    _components.clear();
  }

  @override
  void onMount() {
    game.gestureDetectors.add(
      TapGestureRecognizer.new,
      (TapGestureRecognizer instance) {
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
    game.gestureDetectors.remove<TapGestureRecognizer>();
    game.unregisterKey(const TertiaryTapDispatcherKey());
  }
}
