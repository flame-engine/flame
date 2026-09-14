import 'package:flame/src/game/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class GestureDetectorBuilder {
  GestureDetectorBuilder([this._onChange]);

  final Map<Type, GestureRecognizerFactory> _factories = {};
  final void Function()? _onChange;

  /// Registers a gesture recognizer of type [T].
  ///
  /// Throws a [StateError] if [T] is already registered.
  void register<T extends GestureRecognizer>(
    T Function() constructor,
    void Function(T) initializer,
  ) {
    if (_factories.containsKey(T)) {
      throw StateError('Recognizer of type $T is already registered.');
    }
    _factories[T] = GestureRecognizerFactoryWithHandlers<T>(
      constructor,
      initializer,
    );
    _onChange?.call();
  }

  /// Removes the registration for type [T].
  void unregister<T extends GestureRecognizer>() {
    _factories.remove(T);
    _onChange?.call();
  }

  Widget build(Widget child) {
    if (_factories.isEmpty) {
      return child;
    }
    return RawGestureDetector(
      gestures: _factories,
      behavior: HitTestBehavior.deferToChild,
      child: child,
    );
  }
}

bool hasMouseDetectors(Game game) {
  return game.mouseDetector != null ||
      game.mousePressDetector != null ||
      game.scrollDetector != null;
}

Widget applyMouseDetectors(Game game, Widget child) {
  final mouseDetector = game.mouseDetector;
  final mousePressDetector = game.mousePressDetector;
  final scrollDetector = game.scrollDetector;
  return Listener(
    // Forward pointer-down to the dispatcher so it can fire `onHoverCancel`
    // on hovered HoverCallbacks components — Flutter stops emitting
    // PointerHoverEvents the moment a button is pressed, so without this hook
    // the hover state would silently linger. See issue #2741.
    onPointerDown: mousePressDetector,
    onPointerSignal: (event) {
      if (event is PointerScrollEvent) {
        scrollDetector?.call(event);
      }
    },
    child: MouseRegion(
      onHover: mouseDetector,
      child: child,
    ),
  );
}
