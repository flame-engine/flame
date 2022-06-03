import 'package:flame/events.dart';
import 'package:flame/src/events/flame_drag_adapter.dart';
import 'package:flame/src/game/mixins/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

bool hasBasicGestureDetectors(Game game) {
  return game is TapDetector ||
      game is SecondaryTapDetector ||
      game is DoubleTapDetector ||
      game is LongPressDetector ||
      game is VerticalDragDetector ||
      game is HorizontalDragDetector ||
      game is ForcePressDetector ||
      game is PanDetector ||
      game is ScaleDetector;
}

bool hasAdvancedGestureDetectors(Game game) {
  return game is MultiTapListener ||
      game is MultiTouchDragDetector ||
      game is HasDraggables;
}

bool hasMouseDetectors(Game game) {
  return game is MouseMovementDetector ||
      game is ScrollDetector ||
      game is HasHoverables;
}

Widget applyBasicGesturesDetectors(Game game, Widget child) {
  return GestureDetector(
    key: const ObjectKey('BasicGesturesDetector'),
    behavior: HitTestBehavior.opaque,

    // Taps
    onTap: game is TapDetector ? () => game.onTap() : null,
    onTapCancel: game is TapDetector ? () => game.onTapCancel() : null,
    onTapDown: game is TapDetector
        ? (TapDownDetails d) => game.onTapDown(TapDownInfo.fromDetails(game, d))
        : null,
    onTapUp: game is TapDetector
        ? (TapUpDetails d) => game.onTapUp(TapUpInfo.fromDetails(game, d))
        : null,

    // Secondary taps
    onSecondaryTapDown: game is SecondaryTapDetector
        ? (TapDownDetails d) =>
            game.onSecondaryTapDown(TapDownInfo.fromDetails(game, d))
        : null,
    onSecondaryTapUp: game is SecondaryTapDetector
        ? (TapUpDetails d) =>
            game.onSecondaryTapUp(TapUpInfo.fromDetails(game, d))
        : null,
    onSecondaryTapCancel:
        game is SecondaryTapDetector ? () => game.onSecondaryTapCancel() : null,

    // Double tap
    onDoubleTap: game is DoubleTapDetector ? () => game.onDoubleTap() : null,
    onDoubleTapCancel:
        game is DoubleTapDetector ? () => game.onDoubleTapCancel() : null,
    onDoubleTapDown: game is DoubleTapDetector
        ? (TapDownDetails d) =>
            game.onDoubleTapDown(TapDownInfo.fromDetails(game, d))
        : null,

    // Long presses
    onLongPress: game is LongPressDetector ? () => game.onLongPress() : null,
    onLongPressStart: game is LongPressDetector
        ? (LongPressStartDetails d) =>
            game.onLongPressStart(LongPressStartInfo.fromDetails(game, d))
        : null,
    onLongPressMoveUpdate: game is LongPressDetector
        ? (LongPressMoveUpdateDetails d) => game
            .onLongPressMoveUpdate(LongPressMoveUpdateInfo.fromDetails(game, d))
        : null,
    onLongPressUp:
        game is LongPressDetector ? () => game.onLongPressUp() : null,
    onLongPressEnd: game is LongPressDetector
        ? (LongPressEndDetails d) =>
            game.onLongPressEnd(LongPressEndInfo.fromDetails(game, d))
        : null,

    // Vertical drag
    onVerticalDragDown: game is VerticalDragDetector
        ? (DragDownDetails d) =>
            game.onVerticalDragDown(DragDownInfo.fromDetails(game, d))
        : null,
    onVerticalDragStart: game is VerticalDragDetector
        ? (DragStartDetails d) =>
            game.onVerticalDragStart(DragStartInfo.fromDetails(game, d))
        : null,
    onVerticalDragUpdate: game is VerticalDragDetector
        ? (DragUpdateDetails d) =>
            game.onVerticalDragUpdate(DragUpdateInfo.fromDetails(game, d))
        : null,
    onVerticalDragEnd: game is VerticalDragDetector
        ? (DragEndDetails d) =>
            game.onVerticalDragEnd(DragEndInfo.fromDetails(game, d))
        : null,
    onVerticalDragCancel:
        game is VerticalDragDetector ? () => game.onVerticalDragCancel() : null,

    // Horizontal drag
    onHorizontalDragDown: game is HorizontalDragDetector
        ? (DragDownDetails d) =>
            game.onHorizontalDragDown(DragDownInfo.fromDetails(game, d))
        : null,
    onHorizontalDragStart: game is HorizontalDragDetector
        ? (DragStartDetails d) =>
            game.onHorizontalDragStart(DragStartInfo.fromDetails(game, d))
        : null,
    onHorizontalDragUpdate: game is HorizontalDragDetector
        ? (DragUpdateDetails d) =>
            game.onHorizontalDragUpdate(DragUpdateInfo.fromDetails(game, d))
        : null,
    onHorizontalDragEnd: game is HorizontalDragDetector
        ? (DragEndDetails d) =>
            game.onHorizontalDragEnd(DragEndInfo.fromDetails(game, d))
        : null,
    onHorizontalDragCancel: game is HorizontalDragDetector
        ? () => game.onHorizontalDragCancel()
        : null,

    // Force presses
    onForcePressStart: game is ForcePressDetector
        ? (ForcePressDetails d) =>
            game.onForcePressStart(ForcePressInfo.fromDetails(game, d))
        : null,
    onForcePressPeak: game is ForcePressDetector
        ? (ForcePressDetails d) =>
            game.onForcePressPeak(ForcePressInfo.fromDetails(game, d))
        : null,
    onForcePressUpdate: game is ForcePressDetector
        ? (ForcePressDetails d) =>
            game.onForcePressUpdate(ForcePressInfo.fromDetails(game, d))
        : null,
    onForcePressEnd: game is ForcePressDetector
        ? (ForcePressDetails d) =>
            game.onForcePressEnd(ForcePressInfo.fromDetails(game, d))
        : null,

    // Pan
    onPanDown: game is PanDetector
        ? (DragDownDetails d) =>
            game.onPanDown(DragDownInfo.fromDetails(game, d))
        : null,
    onPanStart: game is PanDetector
        ? (DragStartDetails d) =>
            game.onPanStart(DragStartInfo.fromDetails(game, d))
        : null,
    onPanUpdate: game is PanDetector
        ? (DragUpdateDetails d) =>
            game.onPanUpdate(DragUpdateInfo.fromDetails(game, d))
        : null,
    onPanEnd: game is PanDetector
        ? (DragEndDetails d) => game.onPanEnd(DragEndInfo.fromDetails(game, d))
        : null,
    onPanCancel: game is PanDetector ? () => game.onPanCancel() : null,

    // Scales
    onScaleStart: game is ScaleDetector
        ? (ScaleStartDetails d) =>
            game.onScaleStart(ScaleStartInfo.fromDetails(game, d))
        : null,
    onScaleUpdate: game is ScaleDetector
        ? (ScaleUpdateDetails d) =>
            game.onScaleUpdate(ScaleUpdateInfo.fromDetails(game, d))
        : null,
    onScaleEnd: game is ScaleDetector
        ? (ScaleEndDetails d) =>
            game.onScaleEnd(ScaleEndInfo.fromDetails(game, d))
        : null,

    child: child,
  );
}

Widget applyAdvancedGesturesDetectors(Game game, Widget child) {
  final gestures = <Type, GestureRecognizerFactory>{};

  void addRecognizer<T extends GestureRecognizer>(
    T Function() factory,
    void Function(T) handlers,
  ) {
    gestures[T] = GestureRecognizerFactoryWithHandlers<T>(factory, handlers);
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
