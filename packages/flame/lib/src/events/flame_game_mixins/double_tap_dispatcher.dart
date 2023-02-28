import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/component_mixins/double_tap_callbacks.dart';
import 'package:flame/src/events/messages/double_tap_cancel_event.dart';
import 'package:flame/src/events/messages/double_tap_down_event.dart';
import 'package:flame/src/events/messages/double_tap_event.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

/// [DoubleTapDispatcher] propagates double-tap events to every components in
/// the component tree that is mixed with [DoubleTapCallbacks]. This will be
/// attached to the [FlameGame] instance automatically whenever any
/// [DoubleTapCallbacks] are mounted into the component tree.
@internal
class DoubleTapDispatcher extends Component with HasGameRef<FlameGame> {
  final _components = <DoubleTapCallbacks>{};
  bool _eventHandlerRegistered = false;

  void _onDoubleTapDown(DoubleTapDownEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (DoubleTapCallbacks component) {
        _components.add(component..onDoubleTapDown(event));
      },
    );
  }

  void _onDoubleTapUp(DoubleTapEvent event) {
    _components.forEach((component) => component.onDoubleTapUp(event));
    _components.clear();
  }

  void _onDoubleTapCancel(DoubleTapCancelEvent event) {
    _components.forEach((component) => component.onDoubleTapCancel(event));
    _components.clear();
  }

  @override
  void onMount() {
    if (game.firstChild<DoubleTapDispatcher>() == null) {
      game.gestureDetectors.add(
        DoubleTapGestureRecognizer.new,
        (DoubleTapGestureRecognizer instance) {
          instance.onDoubleTapDown =
              (details) => _onDoubleTapDown(DoubleTapDownEvent(details));
          instance.onDoubleTapCancel =
              () => _onDoubleTapCancel(DoubleTapCancelEvent());
          instance.onDoubleTap = () => _onDoubleTapUp(DoubleTapEvent());
        },
      );
      _eventHandlerRegistered = true;
    } else {
      removeFromParent();
    }
  }

  @override
  void onRemove() {
    if (!_eventHandlerRegistered) {
      return;
    }

    game.gestureDetectors.remove<DoubleTapGestureRecognizer>();
    _eventHandlerRegistered = false;
  }
}
