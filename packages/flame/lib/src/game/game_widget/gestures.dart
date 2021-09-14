import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../../components.dart';
import '../../../extensions.dart';
import '../../components/mixins/draggable.dart';
import '../../extensions/offset.dart';
import '../../gestures/detectors.dart';
import '../../gestures/events.dart';
import '../mixins/game.dart';

bool hasBasicGestureDetectors(Game game) =>
    game is TapDetector ||
    game is SecondaryTapDetector ||
    game is DoubleTapDetector ||
    game is LongPressDetector ||
    game is VerticalDragDetector ||
    game is HorizontalDragDetector ||
    game is ForcePressDetector ||
    game is PanDetector ||
    game is ScaleDetector;

bool hasAdvancedGesturesDetectors(Game game) =>
    game is MultiTouchTapDetector ||
    game is MultiTouchDragDetector ||
    game is HasTappableComponents ||
    game is HasDraggableComponents;

bool hasMouseDetectors(Game game) =>
    game is MouseMovementDetector ||
    game is ScrollDetector ||
    game is HasHoverableComponents;

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
  var lastGeneratedDragId = 0;

  void addAndConfigureRecognizer<T extends GestureRecognizer>(
    T Function() ts,
    void Function(T) bindHandlers,
  ) {
    gestures[T] = GestureRecognizerFactoryWithHandlers<T>(
      ts,
      bindHandlers,
    );
  }

  void addTapRecognizer(void Function(MultiTapGestureRecognizer) config) {
    addAndConfigureRecognizer(
      () => MultiTapGestureRecognizer(),
      config,
    );
  }

  void addDragRecognizer(Game game, Drag Function(int, DragStartInfo) config) {
    addAndConfigureRecognizer(
      () => ImmediateMultiDragGestureRecognizer(),
      (ImmediateMultiDragGestureRecognizer instance) {
        instance.onStart = (Offset o) {
          final pointerId = lastGeneratedDragId++;

          final global = o;
          final local = game
              .convertGlobalToLocalCoordinate(
                global.toVector2(),
              )
              .toOffset();

          final details = DragStartDetails(
            localPosition: local,
            globalPosition: global,
          );
          return config(
            pointerId,
            DragStartInfo.fromDetails(game, details),
          );
        };
      },
    );
  }

  if (game is MultiTouchTapDetector) {
    addTapRecognizer((MultiTapGestureRecognizer instance) {
      instance.onTapDown =
          (i, d) => game.onTapDown(i, TapDownInfo.fromDetails(game, d));
      instance.onTapUp =
          (i, d) => game.onTapUp(i, TapUpInfo.fromDetails(game, d));
      instance.onTapCancel = game.onTapCancel;
      instance.onTap = game.onTap;
    });
  } else if (game is HasTappableComponents) {
    addAndConfigureRecognizer(
      () => MultiTapGestureRecognizer(),
      (MultiTapGestureRecognizer instance) {
        instance.onTapDown =
            (i, d) => game.onTapDown(i, TapDownInfo.fromDetails(game, d));
        instance.onTapUp =
            (i, d) => game.onTapUp(i, TapUpInfo.fromDetails(game, d));
        instance.onTapCancel = (i) => game.onTapCancel(i);
      },
    );
  }

  if (game is MultiTouchDragDetector) {
    addDragRecognizer(game, (int pointerId, DragStartInfo info) {
      game.onDragStart(pointerId, info);
      return _DragEvent(game)
        ..onUpdate = ((details) => game.onDragUpdate(pointerId, details))
        ..onEnd = ((details) => game.onDragEnd(pointerId, details))
        ..onCancel = (() => game.onDragCancel(pointerId));
    });
  } else if (game is HasDraggableComponents) {
    addDragRecognizer(game, (int pointerId, DragStartInfo position) {
      game.onDragStart(pointerId, position);
      return _DragEvent(game)
        ..onUpdate = ((details) => game.onDragUpdate(pointerId, details))
        ..onEnd = ((details) => game.onDragEnd(pointerId, details))
        ..onCancel = (() => game.onDragCancel(pointerId));
    });
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
      : (game is HasHoverableComponents ? game.onMouseMove : null);
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

class _DragEvent extends Drag {
  final Game gameRef;
  void Function(DragUpdateInfo)? onUpdate;
  VoidCallback? onCancel;
  void Function(DragEndInfo)? onEnd;

  _DragEvent(this.gameRef);

  @override
  void update(DragUpdateDetails details) {
    final event = DragUpdateInfo.fromDetails(gameRef, details);
    onUpdate?.call(event);
  }

  @override
  void cancel() {
    onCancel?.call();
  }

  @override
  void end(DragEndDetails details) {
    final event = DragEndInfo.fromDetails(gameRef, details);
    onEnd?.call(event);
  }
}
