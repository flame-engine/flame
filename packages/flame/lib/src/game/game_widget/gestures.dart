import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../../extensions.dart';
import '../../components/mixins/draggable.dart';
import '../../components/mixins/tapable.dart';
import '../../extensions/offset.dart';
import '../../gestures/detectors.dart';
import '../../gestures/events.dart';
import '../game.dart';

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
    game is HasTapableComponents ||
    game is HasDraggableComponents;

bool hasMouseDetectors(Game game) =>
    game is MouseMovementDetector || game is ScrollDetector;

TapDownInfo _parseTapDownDetails(Game game, TapDownDetails details) {
  return TapDownInfo(
    game.projectCoordinate(details.localPosition),
    details,
  );
}

TapUpInfo _parseTapUpDetails(Game game, TapUpDetails details) {
  return TapUpInfo(
    game.projectCoordinate(details.localPosition),
    details,
  );
}

LongPressStartInfo _parseLongPressStartDetaills(
    Game game, LongPressStartDetails details) {
  return LongPressStartInfo(
    game.projectCoordinate(details.localPosition),
    details,
  );
}

LongPressEndInfo _parseLongPressEndDetaills(
    Game game, LongPressEndDetails details) {
  return LongPressEndInfo(
    game.projectCoordinate(details.localPosition),
    details.velocity,
    details,
  );
}

LongPressMoveUpdateInfo _parseLongPressMoveUpdateDetaills(
    Game game, LongPressMoveUpdateDetails details) {
  return LongPressMoveUpdateInfo(
    game.projectCoordinate(details.localPosition),
    details,
  );
}

DragDownInfo _parseDragDownInfo(Game game, DragDownDetails details) {
  return DragDownInfo(
    game.projectCoordinate(details.localPosition),
    details,
  );
}

DragStartInfo _parseDragStartInfo(Game game, DragStartDetails details) {
  return DragStartInfo(
    game.projectCoordinate(details.localPosition),
    details,
  );
}

DragUpdateInfo _parseDragUpdateInfo(Game game, DragUpdateDetails details) {
  return DragUpdateInfo(
    game.projectCoordinate(details.localPosition),
    // Should this be projected as well?
    details.delta.toVector2(),
    details,
  );
}

DragEndInfo _parseDragEndInfo(DragEndDetails details) {
  return DragEndInfo(
    details.velocity,
    details.primaryVelocity,
    details,
  );
}

ForcePressInfo _parseForcePressDetails(Game game, ForcePressDetails details) {
  return ForcePressInfo(
    game.projectCoordinate(details.localPosition),
    details.pressure,
    details,
  );
}

ScaleStartInfo _parseScaleStartDetails(Game game, ScaleStartDetails details) {
  return ScaleStartInfo(
    game.projectCoordinate(details.localFocalPoint),
    details.pointerCount,
    details,
  );
}

ScaleEndInfo _parseScaleEndDetails(ScaleEndDetails details) {
  return ScaleEndInfo(
    details.velocity,
    details.pointerCount,
    details,
  );
}

ScaleUpdateInfo _parseScaleUpdateDetails(
    Game game, ScaleUpdateDetails details) {
  return ScaleUpdateInfo(
    game.projectCoordinate(details.localFocalPoint),
    details.pointerCount,
    details.rotation,
    details.horizontalScale,
    details.verticalScale,
    details,
  );
}

PointerHoverInfo _parsePointerHoverEvent(Game game, PointerHoverEvent event) {
  return PointerHoverInfo(
    game.projectCoordinate(event.localPosition),
    event,
  );
}

PointerScrollInfo _parsePointerScrollEvent(
    Game game, PointerScrollEvent event) {
  return PointerScrollInfo(
    game.projectCoordinate(event.localPosition),
    event,
  );
}

Widget applyBasicGesturesDetectors(Game game, Widget child) {
  return GestureDetector(
    key: const ObjectKey('BasicGesturesDetector'),
    behavior: HitTestBehavior.opaque,

    // Taps
    onTap: game is TapDetector ? () => game.onTap() : null,
    onTapCancel: game is TapDetector ? () => game.onTapCancel() : null,
    onTapDown: game is TapDetector
        ? (TapDownDetails d) => game.onTapDown(_parseTapDownDetails(game, d))
        : null,
    onTapUp: game is TapDetector
        ? (TapUpDetails d) => game.onTapUp(_parseTapUpDetails(game, d))
        : null,

    // Secondary taps
    onSecondaryTapDown: game is SecondaryTapDetector
        ? (TapDownDetails d) =>
            game.onSecondaryTapDown(_parseTapDownDetails(game, d))
        : null,
    onSecondaryTapUp: game is SecondaryTapDetector
        ? (TapUpDetails d) => game.onSecondaryTapUp(_parseTapUpDetails(game, d))
        : null,
    onSecondaryTapCancel:
        game is SecondaryTapDetector ? () => game.onSecondaryTapCancel() : null,

    // Double tap
    onDoubleTap: game is DoubleTapDetector ? () => game.onDoubleTap() : null,

    // Long presses
    onLongPress: game is LongPressDetector ? () => game.onLongPress() : null,
    onLongPressStart: game is LongPressDetector
        ? (LongPressStartDetails d) =>
            game.onLongPressStart(_parseLongPressStartDetaills(game, d))
        : null,
    onLongPressMoveUpdate: game is LongPressDetector
        ? (LongPressMoveUpdateDetails d) => game
            .onLongPressMoveUpdate(_parseLongPressMoveUpdateDetaills(game, d))
        : null,
    onLongPressUp:
        game is LongPressDetector ? () => game.onLongPressUp() : null,
    onLongPressEnd: game is LongPressDetector
        ? (LongPressEndDetails d) =>
            game.onLongPressEnd(_parseLongPressEndDetaills(game, d))
        : null,

    // Vertical drag
    onVerticalDragDown: game is VerticalDragDetector
        ? (DragDownDetails d) =>
            game.onVerticalDragDown(_parseDragDownInfo(game, d))
        : null,
    onVerticalDragStart: game is VerticalDragDetector
        ? (DragStartDetails d) =>
            game.onVerticalDragStart(_parseDragStartInfo(game, d))
        : null,
    onVerticalDragUpdate: game is VerticalDragDetector
        ? (DragUpdateDetails d) =>
            game.onVerticalDragUpdate(_parseDragUpdateInfo(game, d))
        : null,
    onVerticalDragEnd: game is VerticalDragDetector
        ? (DragEndDetails d) => game.onVerticalDragEnd(_parseDragEndInfo(d))
        : null,
    onVerticalDragCancel:
        game is VerticalDragDetector ? () => game.onVerticalDragCancel() : null,

    // Horizontal drag
    onHorizontalDragDown: game is HorizontalDragDetector
        ? (DragDownDetails d) =>
            game.onHorizontalDragDown(_parseDragDownInfo(game, d))
        : null,
    onHorizontalDragStart: game is HorizontalDragDetector
        ? (DragStartDetails d) =>
            game.onHorizontalDragStart(_parseDragStartInfo(game, d))
        : null,
    onHorizontalDragUpdate: game is HorizontalDragDetector
        ? (DragUpdateDetails d) =>
            game.onHorizontalDragUpdate(_parseDragUpdateInfo(game, d))
        : null,
    onHorizontalDragEnd: game is HorizontalDragDetector
        ? (DragEndDetails d) => game.onHorizontalDragEnd(_parseDragEndInfo(d))
        : null,
    onHorizontalDragCancel: game is HorizontalDragDetector
        ? () => game.onHorizontalDragCancel()
        : null,

    // Force presses
    onForcePressStart: game is ForcePressDetector
        ? (ForcePressDetails d) =>
            game.onForcePressStart(_parseForcePressDetails(game, d))
        : null,
    onForcePressPeak: game is ForcePressDetector
        ? (ForcePressDetails d) =>
            game.onForcePressPeak(_parseForcePressDetails(game, d))
        : null,
    onForcePressUpdate: game is ForcePressDetector
        ? (ForcePressDetails d) =>
            game.onForcePressUpdate(_parseForcePressDetails(game, d))
        : null,
    onForcePressEnd: game is ForcePressDetector
        ? (ForcePressDetails d) =>
            game.onForcePressEnd(_parseForcePressDetails(game, d))
        : null,

    // Pan
    onPanDown: game is PanDetector
        ? (DragDownDetails d) => game.onPanDown(_parseDragDownInfo(game, d))
        : null,
    onPanStart: game is PanDetector
        ? (DragStartDetails d) => game.onPanStart(_parseDragStartInfo(game, d))
        : null,
    onPanUpdate: game is PanDetector
        ? (DragUpdateDetails d) =>
            game.onPanUpdate(_parseDragUpdateInfo(game, d))
        : null,
    onPanEnd: game is PanDetector
        ? (DragEndDetails d) => game.onPanEnd(_parseDragEndInfo(d))
        : null,
    onPanCancel: game is PanDetector ? () => game.onPanCancel() : null,

    // Scales
    onScaleStart: game is ScaleDetector
        ? (ScaleStartDetails d) =>
            game.onScaleStart(_parseScaleStartDetails(game, d))
        : null,
    onScaleUpdate: game is ScaleDetector
        ? (ScaleUpdateDetails d) =>
            game.onScaleUpdate(_parseScaleUpdateDetails(game, d))
        : null,
    onScaleEnd: game is ScaleDetector
        ? (ScaleEndDetails d) => game.onScaleEnd(_parseScaleEndDetails(d))
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

  void addDragRecognizer(Drag Function(int, Vector2) config) {
    addAndConfigureRecognizer(
      () => ImmediateMultiDragGestureRecognizer(),
      (ImmediateMultiDragGestureRecognizer instance) {
        instance.onStart = (Offset o) {
          final pointerId = lastGeneratedDragId++;
          final position = game.convertGlobalToLocalCoordinate(o.toVector2());
          return config(pointerId, position);
        };
      },
    );
  }

  if (game is MultiTouchTapDetector) {
    addTapRecognizer((MultiTapGestureRecognizer instance) {
      instance.onTapDown =
          (i, d) => game.onTapDown(i, _parseTapDownDetails(game, d));
      instance.onTapUp = (i, d) => game.onTapUp(i, _parseTapUpDetails(game, d));
      instance.onTapCancel = game.onTapCancel;
      instance.onTap = game.onTap;
    });
  } else if (game is HasTapableComponents) {
    addAndConfigureRecognizer(
      () => MultiTapGestureRecognizer(),
      (MultiTapGestureRecognizer instance) {
        instance.onTapDown = game.onTapDown;
        instance.onTapUp = game.onTapUp;
        instance.onTapCancel = game.onTapCancel;
      },
    );
  }

  if (game is MultiTouchDragDetector) {
    addDragRecognizer((int pointerId, Vector2 position) {
      game.onDragStart(pointerId, position);
      return _DragEvent(game)
        ..onUpdate = ((details) => game.onDragUpdate(pointerId, details))
        ..onEnd = ((details) => game.onDragEnd(pointerId, details))
        ..onCancel = (() => game.onDragCancel(pointerId));
    });
  } else if (game is HasDraggableComponents) {
    addDragRecognizer((int pointerId, Vector2 position) {
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
  return Listener(
    child: MouseRegion(
      child: child,
      onHover: game is MouseMovementDetector
          ? (e) => game.onMouseMove(_parsePointerHoverEvent(game, e))
          : null,
    ),
    onPointerSignal: (event) =>
        game is ScrollDetector && event is PointerScrollEvent
            ? game.onScroll(_parsePointerScrollEvent(game, event))
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
    final event = _parseDragUpdateInfo(gameRef, details);
    onUpdate?.call(event);
  }

  @override
  void cancel() {
    onCancel?.call();
  }

  @override
  void end(DragEndDetails details) {
    final event = _parseDragEndInfo(details);
    onEnd?.call(event);
  }
}
