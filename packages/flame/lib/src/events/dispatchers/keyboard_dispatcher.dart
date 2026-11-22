import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart' as flutter;
import 'package:meta/meta.dart';

/// **KeyboardDispatcher** facilitates dispatching of keyboard events to the
/// [KeyboardCallbacks] components in the component tree. It will be attached
/// to the [FlameGame] instance automatically whenever any
/// [KeyboardCallbacks] components are mounted into the component tree.
class KeyboardDispatcher() extends Dispatcher<FlameGame> {
  @mustCallSuper
  void onKeyboardEvent(KeyboardEvent event) {
    event.deliverToComponents(
      gameRef,
      (KeyboardCallbacks component) {
        component.onKeyboardEvent(event);
      },
      deliverToAll: true,
    );
  }

  void _handleKeyEvent(flutter.KeyEvent event) {
    onKeyboardEvent(KeyboardEvent.fromKeyEvent(event));
  }

  static void addDispatcher(Component component) {
    Dispatcher.addDispatcher(
      component,
      const KeyboardDispatcherKey(),
      KeyboardDispatcher.new,
    );
  }

  @override
  void onMount() {
    gameRef.keyDetector = _handleKeyEvent;
  }

  @override
  void onRemove() {
    gameRef.keyDetector = null;
    Dispatcher.removeDispatcher(gameRef, const KeyboardDispatcherKey());
  }
}

/// Unique key for the [KeyboardDispatcher] so the game can identify it.
class const KeyboardDispatcherKey() implements ComponentKey {
  @override
  int get hashCode => 'KeyboardDispatcherKey'.hashCode;

  @override
  bool operator ==(Object other) {
    return other is KeyboardDispatcherKey && other.hashCode == hashCode;
  }
}
