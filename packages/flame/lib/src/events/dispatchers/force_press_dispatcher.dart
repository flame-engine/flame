import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

/// **ForcePressDispatcher** facilitates dispatching of force press events to
/// the [ForcePressCallbacks] components in the component tree. It will be
/// attached to the [FlameGame] instance automatically whenever any
/// [ForcePressCallbacks] components are mounted into the component tree.
///
/// Flutter's [ForcePressGestureRecognizer] tracks a single pointer at a time,
/// so this dispatcher only needs to remember the set of components that
/// accepted the current gesture, rather than keying them by pointer id.
class ForcePressDispatcher extends Dispatcher<FlameGame> {
  /// The components that received the current gesture's start event, and which
  /// will therefore receive its peak, update and end events.
  final Set<ForcePressCallbacks> _components = {};

  @mustCallSuper
  void onForcePressStart(ForcePressEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (ForcePressCallbacks component) {
        _components.add(component..onForcePressStart(event));
      },
    );
  }

  @mustCallSuper
  void onForcePressPeak(ForcePressEvent event) {
    _forEachActiveComponent((component) => component.onForcePressPeak(event));
  }

  @mustCallSuper
  void onForcePressUpdate(ForcePressEvent event) {
    _forEachActiveComponent((component) => component.onForcePressUpdate(event));
  }

  @mustCallSuper
  void onForcePressEnd(ForcePressEvent event) {
    _forEachActiveComponent((component) => component.onForcePressEnd(event));
    _components.clear();
  }

  /// Delivers to every component that accepted the gesture and is still
  /// mounted, dropping the ones that were removed mid-gesture.
  void _forEachActiveComponent(void Function(ForcePressCallbacks) handler) {
    _components.removeWhere((component) => !component.isMounted);
    for (final component in _components) {
      handler(component);
    }
  }

  //#region Gesture recognizer handlers

  @internal
  void handleForcePressStart(ForcePressDetails details) {
    onForcePressStart(ForcePressEvent(game, details));
  }

  @internal
  void handleForcePressPeak(ForcePressDetails details) {
    onForcePressPeak(ForcePressEvent(game, details));
  }

  @internal
  void handleForcePressUpdate(ForcePressDetails details) {
    onForcePressUpdate(ForcePressEvent(game, details));
  }

  @internal
  void handleForcePressEnd(ForcePressDetails details) {
    onForcePressEnd(ForcePressEvent(game, details));
  }

  //#endregion

  static void addDispatcher(Component component) {
    Dispatcher.addDispatcher(
      component,
      const ForcePressDispatcherKey(),
      ForcePressDispatcher.new,
    );
  }

  @override
  void onMount() {
    game.gestureDetectors.register<ForcePressGestureRecognizer>(
      ForcePressGestureRecognizer.new,
      (ForcePressGestureRecognizer instance) {
        instance
          ..onStart = handleForcePressStart
          ..onPeak = handleForcePressPeak
          ..onUpdate = handleForcePressUpdate
          ..onEnd = handleForcePressEnd;
      },
    );
    super.onMount();
  }

  @override
  void onRemove() {
    game.gestureDetectors.unregister<ForcePressGestureRecognizer>();
    Dispatcher.removeDispatcher(game, const ForcePressDispatcherKey());
  }
}

/// Unique key for the [ForcePressDispatcher] so the game can identify it.
class ForcePressDispatcherKey implements ComponentKey {
  const ForcePressDispatcherKey();

  @override
  int get hashCode => 'ForcePressDispatcherKey'.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ForcePressDispatcherKey && other.hashCode == hashCode;
}
