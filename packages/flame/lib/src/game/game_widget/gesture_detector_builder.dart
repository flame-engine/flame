import 'package:flame/events.dart';
import 'package:flame/input.dart';
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

  void initializeGestures(Game game) {
    // support for deprecated detectors
    // ignore: deprecated_member_use_from_same_package
    if (game is TapDetector ||
        game is SecondaryTapDetector ||
        game is TertiaryTapDetector) {
      register(
        TapGestureRecognizer.new,
        (TapGestureRecognizer instance) {
          // support for deprecated detectors
          // ignore: deprecated_member_use_from_same_package
          if (game is TapDetector) {
            instance.onTap = game.onTap;
            instance.onTapCancel = game.onTapCancel;
            instance.onTapUp = game.handleTapUp;
            instance.onTapDown = game.handleTapDown;
          }
          if (game is SecondaryTapDetector) {
            instance.onSecondaryTapCancel = game.onSecondaryTapCancel;
            instance.onSecondaryTapUp = game.handleSecondaryTapUp;
            instance.onSecondaryTapDown = game.handleSecondaryTapDown;
          }
          if (game is TertiaryTapDetector) {
            instance.onTertiaryTapCancel = game.onTertiaryTapCancel;
            instance.onTertiaryTapUp = game.handleTertiaryTapUp;
            instance.onTertiaryTapDown = game.handleTertiaryTapDown;
          }
        },
      );
    }
    if (game is DoubleTapDetector) {
      register(
        DoubleTapGestureRecognizer.new,
        (DoubleTapGestureRecognizer instance) {
          instance.onDoubleTap = game.onDoubleTap;
          instance.onDoubleTapDown = game.handleDoubleTapDown;
          instance.onDoubleTapCancel = game.onDoubleTapCancel;
        },
      );
    }
    if (game is LongPressDetector) {
      register(
        LongPressGestureRecognizer.new,
        (LongPressGestureRecognizer instance) {
          instance.onLongPress = game.onLongPress;
          instance.onLongPressStart = game.handleLongPressStart;
          instance.onLongPressMoveUpdate = game.handleLongPressMoveUpdate;
          instance.onLongPressEnd = game.handleLongPressEnd;
          instance.onLongPressUp = game.onLongPressUp;
          instance.onLongPressCancel = game.onLongPressCancel;
        },
      );
    }
    if (game is VerticalDragDetector) {
      register(
        VerticalDragGestureRecognizer.new,
        (VerticalDragGestureRecognizer instance) {
          instance.onDown = game.handleVerticalDragDown;
          instance.onStart = game.handleVerticalDragStart;
          instance.onUpdate = game.handleVerticalDragUpdate;
          instance.onEnd = game.handleVerticalDragEnd;
          instance.onCancel = game.onVerticalDragCancel;
        },
      );
    }
    if (game is HorizontalDragDetector) {
      register(
        HorizontalDragGestureRecognizer.new,
        (HorizontalDragGestureRecognizer instance) {
          instance.onDown = game.handleHorizontalDragDown;
          instance.onStart = game.handleHorizontalDragStart;
          instance.onUpdate = game.handleHorizontalDragUpdate;
          instance.onEnd = game.handleHorizontalDragEnd;
          instance.onCancel = game.onHorizontalDragCancel;
        },
      );
    }
    if (game is ForcePressDetector) {
      register(
        ForcePressGestureRecognizer.new,
        (ForcePressGestureRecognizer instance) {
          instance.onStart = game.handleForcePressStart;
          instance.onPeak = game.handleForcePressPeak;
          instance.onUpdate = game.handleForcePressUpdate;
          instance.onEnd = game.handleForcePressEnd;
        },
      );
    }
    if (game is PanDetector) {
      register(
        PanGestureRecognizer.new,
        (PanGestureRecognizer instance) {
          instance.onDown = game.handlePanDown;
          instance.onStart = game.handlePanStart;
          instance.onUpdate = game.handlePanUpdate;
          instance.onEnd = game.handlePanEnd;
          instance.onCancel = game.onPanCancel;
        },
      );
    }
    if (game is ScaleDetector) {
      register(
        ScaleGestureRecognizer.new,
        (ScaleGestureRecognizer instance) {
          instance.onStart = game.handleScaleStart;
          instance.onUpdate = game.handleScaleUpdate;
          instance.onEnd = game.handleScaleEnd;
        },
      );
    }
    if (game is MultiTapListener) {
      register(
        MultiTapGestureRecognizer.new,
        (MultiTapGestureRecognizer instance) {
          final g = game as MultiTapListener;
          instance.longTapDelay = Duration(
            milliseconds: (g.longTapDelay * 1000).toInt(),
          );
          instance.onTap = g.handleTap;
          instance.onTapDown = g.handleTapDown;
          instance.onTapUp = g.handleTapUp;
          instance.onTapCancel = g.handleTapCancel;
          instance.onLongTapDown = g.handleLongTapDown;
        },
      );
    }
  }
}

bool hasMouseDetectors(Game game) {
  return game is MouseMovementDetector ||
      game is ScrollDetector ||
      game.mouseDetector != null ||
      game.mousePressDetector != null ||
      game.scrollDetector != null;
}

Widget applyMouseDetectors(Game game, Widget child) {
  final mouseMoveFn = game is MouseMovementDetector ? game.onMouseMove : null;
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
        if (game is ScrollDetector) {
          game.onScroll(PointerScrollInfo.fromDetails(game, event));
        }
        scrollDetector?.call(event);
      }
    },
    child: MouseRegion(
      onHover: (PointerHoverEvent e) {
        mouseMoveFn?.call(PointerHoverInfo.fromDetails(game, e));
        mouseDetector?.call(e);
      },
      child: child,
    ),
  );
}
