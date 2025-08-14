import 'package:flame/events.dart';
import 'package:flame/src/game/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class GestureDetectorBuilder {
  GestureDetectorBuilder([this._onChange]);

  final Map<Type, GestureRecognizerFactory> _gestures = {};
  final Map<Type, int> _counters = {};
  final void Function()? _onChange;

  void add<T extends GestureRecognizer>(
    T Function() constructor,
    void Function(T) initializer,
  ) {
    final count = _counters[T];
    if (count == null) {
      _gestures[T] = GestureRecognizerFactoryWithHandlers<T>(
        constructor,
        initializer,
      );
      _onChange?.call();
    }
    _counters[T] = (count ?? 0) + 1;
  }

  void remove<T extends GestureRecognizer>() {
    final count = _counters[T]!;
    if (count == 1) {
      _counters.remove(T);
      _gestures.remove(T);
      _onChange?.call();
    } else {
      _counters[T] = count - 1;
    }
  }

  Widget build(Widget child) {
    if (_gestures.isEmpty) {
      return child;
    }
    return RawGestureDetector(
      gestures: _gestures,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }

  void initializeGestures(Game game) {
    if (game is TapDetector ||
        game is SecondaryTapDetector ||
        game is TertiaryTapDetector) {
      add(
        TapGestureRecognizer.new,
        (TapGestureRecognizer instance) {
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
      add(
        DoubleTapGestureRecognizer.new,
        (DoubleTapGestureRecognizer instance) {
          instance.onDoubleTap = game.onDoubleTap;
          instance.onDoubleTapDown = game.handleDoubleTapDown;
          instance.onDoubleTapCancel = game.onDoubleTapCancel;
        },
      );
    }
    if (game is LongPressDetector) {
      add(
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
      add(
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
      add(
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
      add(
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
      add(
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
      add(
        ScaleGestureRecognizer.new,
        (ScaleGestureRecognizer instance) {
          instance.onStart = game.handleScaleStart;
          instance.onUpdate = game.handleScaleUpdate;
          instance.onEnd = game.handleScaleEnd;
        },
      );
    }
    if (game is MultiTapListener) {
      add(
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
      game.mouseDetector != null;
}

Widget applyMouseDetectors(Game game, Widget child) {
  final mouseMoveFn = game is MouseMovementDetector ? game.onMouseMove : null;
  final mouseDetector = game.mouseDetector;
  return Listener(
    child: MouseRegion(
      child: child,
      onHover: (PointerHoverEvent e) {
        mouseMoveFn?.call(PointerHoverInfo.fromDetails(game, e));
        mouseDetector?.call(e);
      },
    ),
    onPointerSignal: (event) =>
        game is ScrollDetector && event is PointerScrollEvent
        ? game.onScroll(PointerScrollInfo.fromDetails(game, event))
        : null,
  );
}
