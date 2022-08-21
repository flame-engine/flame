import 'package:flame/events.dart';
import 'package:flame/src/events/flame_drag_adapter.dart';
import 'package:flame/src/game/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

bool hasGestureDetectors(Game game) {
  return game is TapDetector ||
      game is SecondaryTapDetector ||
      game is TertiaryTapDetector ||
      game is DoubleTapDetector ||
      game is LongPressDetector ||
      game is VerticalDragDetector ||
      game is HorizontalDragDetector ||
      game is ForcePressDetector ||
      game is PanDetector ||
      game is ScaleDetector ||
      game is MultiTapListener ||
      game is MultiDragListener;
}

bool hasMouseDetectors(Game game) {
  return game is MouseMovementDetector ||
      game is ScrollDetector ||
      game is HasHoverables;
}

Widget applyGesturesDetectors(Game game, Widget child) {
  final gestures = <Type, GestureRecognizerFactory>{};

  void addRecognizer<T extends GestureRecognizer>(
    T Function() factory,
    void Function(T) handlers,
  ) {
    gestures[T] = GestureRecognizerFactoryWithHandlers<T>(factory, handlers);
  }

  if (game is TapDetector ||
      game is SecondaryTapDetector ||
      game is TertiaryTapDetector) {
    addRecognizer(
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
    addRecognizer(
      DoubleTapGestureRecognizer.new,
      (DoubleTapGestureRecognizer instance) {
        instance.onDoubleTap = game.onDoubleTap;
        instance.onDoubleTapDown = game.handleDoubleTapDown;
        instance.onDoubleTapCancel = game.onDoubleTapCancel;
      },
    );
  }
  if (game is LongPressDetector) {
    addRecognizer(
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
    addRecognizer(
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
    addRecognizer(
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
    addRecognizer(
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
    addRecognizer(
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
    addRecognizer(
      ScaleGestureRecognizer.new,
      (ScaleGestureRecognizer instance) {
        instance.onStart = game.handleScaleStart;
        instance.onUpdate = game.handleScaleUpdate;
        instance.onEnd = game.handleScaleEnd;
      },
    );
  }
  if (game is MultiTapListener) {
    addRecognizer(
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
  if (game is MultiDragListener) {
    addRecognizer(
      ImmediateMultiDragGestureRecognizer.new,
      (ImmediateMultiDragGestureRecognizer instance) {
        final g = game as MultiDragListener;
        instance.onStart = (Offset point) => FlameDragAdapter(g, point);
      },
    );
  }
  return RawGestureDetector(
    gestures: gestures,
    behavior: HitTestBehavior.opaque,
    child: child,
  );
}

Widget applyMouseDetectors(Game game, Widget child) {
  final mouseMoveFn = game is MouseMovementDetector
      ? game.onMouseMove
      : (game is HasHoverables ? game.onMouseMove : null);
  return Listener(
    child: MouseRegion(
      child: child,
      onHover: (e) => mouseMoveFn?.call(PointerHoverInfo.fromDetails(game, e)),
    ),
    onPointerSignal: (event) =>
        game is ScrollDetector && event is PointerScrollEvent
            ? game.onScroll(PointerScrollInfo.fromDetails(game, event))
            : null,
  );
}
