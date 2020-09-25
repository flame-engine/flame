import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../components/mixins/tapable.dart';
import '../gestures.dart';
import 'embedded_game_widget.dart';
import 'game.dart';

bool _hasBasicGestureDetectors(Game game) =>
    game is TapDetector ||
    game is SecondaryTapDetector ||
    game is DoubleTapDetector ||
    game is LongPressDetector ||
    game is VerticalDragDetector ||
    game is HorizontalDragDetector ||
    game is ForcePressDetector ||
    game is PanDetector ||
    game is ScaleDetector;

bool _hasAdvancedGesturesDetectors(Game game) =>
    game is MultiTouchTapDetector ||
    game is MultiTouchDragDetector ||
    game is HasTapableComponents;

bool _hasMouseDetectors(Game game) =>
    game is MouseMovementDetector || game is ScrollDetector;

class _GenericTapEventHandler {
  void Function(int pointerId) onTap;
  void Function(int pointerId) onTapCancel;
  void Function(int pointerId, TapDownDetails details) onTapDown;
  void Function(int pointerId, TapUpDetails details) onTapUp;
}

Widget _applyAdvancedGesturesDetectors(Game game, Widget child) {
  final Map<Type, GestureRecognizerFactory> gestures =
      <Type, GestureRecognizerFactory>{};

  final List<_GenericTapEventHandler> _tapHandlers = [];

  if (game is HasTapableComponents) {
    _tapHandlers.add(_GenericTapEventHandler()
      ..onTapDown = game.onTapDown
      ..onTapUp = game.onTapUp
      ..onTapCancel = game.onTapCancel);
  }

  if (game is MultiTouchTapDetector) {
    _tapHandlers.add(_GenericTapEventHandler()
      ..onTapDown = game.onTapDown
      ..onTapUp = game.onTapUp
      ..onTapCancel = game.onTapCancel);
  }

  if (_tapHandlers.isNotEmpty) {
    gestures[MultiTapGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<MultiTapGestureRecognizer>(
      () => MultiTapGestureRecognizer(),
      (MultiTapGestureRecognizer instance) {
        instance.onTapDown = (pointerId, d) =>
            _tapHandlers.forEach((h) => h.onTapDown?.call(pointerId, d));
        instance.onTapUp = (pointerId, d) =>
            _tapHandlers.forEach((h) => h.onTapUp?.call(pointerId, d));
        instance.onTapCancel = (pointerId) =>
            _tapHandlers.forEach((h) => h.onTapCancel?.call(pointerId));
        instance.onTap = (pointerId) =>
            _tapHandlers.forEach((h) => h.onTap?.call(pointerId));
      },
    );
  }

  if (game is MultiTouchDragDetector) {
    gestures[ImmediateMultiDragGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<
            ImmediateMultiDragGestureRecognizer>(
      () => ImmediateMultiDragGestureRecognizer(),
      (ImmediateMultiDragGestureRecognizer instance) {
        instance
          ..onStart = (Offset o) {
            final drag = DragEvent();
            drag.initialPosition = o;

            game.onReceiveDrag(drag);

            return drag;
          };
      },
    );
  }

  return RawGestureDetector(
    gestures: gestures,
    child: Container(
        color: game.backgroundColor(),
        child: Directionality(
            textDirection: TextDirection.ltr, child: EmbeddedGameWidget(game))),
  );
}

Widget _applyBasicGesturesDetectors(Game game, Widget child) {
  return GestureDetector(
    // Taps
    onTap: game is TapDetector ? () => game.onTap() : null,
    onTapCancel: game is TapDetector ? () => game.onTapCancel() : null,
    onTapDown:
        game is TapDetector ? (TapDownDetails d) => game.onTapDown(d) : null,
    onTapUp: game is TapDetector ? (TapUpDetails d) => game.onTapUp(d) : null,

    // Secondary taps
    onSecondaryTapDown: game is SecondaryTapDetector
        ? (TapDownDetails d) => game.onSecondaryTapDown(d)
        : null,
    onSecondaryTapUp: game is SecondaryTapDetector
        ? (TapUpDetails d) => game.onSecondaryTapUp(d)
        : null,
    onSecondaryTapCancel:
        game is SecondaryTapDetector ? () => game.onSecondaryTapCancel() : null,

    // Double tap
    onDoubleTap: game is DoubleTapDetector ? () => game.onDoubleTap() : null,

    // Long presses
    onLongPress: game is LongPressDetector ? () => game.onLongPress() : null,
    onLongPressStart: game is LongPressDetector
        ? (LongPressStartDetails d) => game.onLongPressStart(d)
        : null,
    onLongPressMoveUpdate: game is LongPressDetector
        ? (LongPressMoveUpdateDetails d) => game.onLongPressMoveUpdate(d)
        : null,
    onLongPressUp:
        game is LongPressDetector ? () => game.onLongPressUp() : null,
    onLongPressEnd: game is LongPressDetector
        ? (LongPressEndDetails d) => game.onLongPressEnd(d)
        : null,

    // Vertical drag
    onVerticalDragDown: game is VerticalDragDetector
        ? (DragDownDetails d) => game.onVerticalDragDown(d)
        : null,
    onVerticalDragStart: game is VerticalDragDetector
        ? (DragStartDetails d) => game.onVerticalDragStart(d)
        : null,
    onVerticalDragUpdate: game is VerticalDragDetector
        ? (DragUpdateDetails d) => game.onVerticalDragUpdate(d)
        : null,
    onVerticalDragEnd: game is VerticalDragDetector
        ? (DragEndDetails d) => game.onVerticalDragEnd(d)
        : null,
    onVerticalDragCancel:
        game is VerticalDragDetector ? () => game.onVerticalDragCancel() : null,

    // Horizontal drag
    onHorizontalDragDown: game is HorizontalDragDetector
        ? (DragDownDetails d) => game.onHorizontalDragDown(d)
        : null,
    onHorizontalDragStart: game is HorizontalDragDetector
        ? (DragStartDetails d) => game.onHorizontalDragStart(d)
        : null,
    onHorizontalDragUpdate: game is HorizontalDragDetector
        ? (DragUpdateDetails d) => game.onHorizontalDragUpdate(d)
        : null,
    onHorizontalDragEnd: game is HorizontalDragDetector
        ? (DragEndDetails d) => game.onHorizontalDragEnd(d)
        : null,
    onHorizontalDragCancel: game is HorizontalDragDetector
        ? () => game.onHorizontalDragCancel()
        : null,

    // Force presses
    onForcePressStart: game is ForcePressDetector
        ? (ForcePressDetails d) => game.onForcePressStart(d)
        : null,
    onForcePressPeak: game is ForcePressDetector
        ? (ForcePressDetails d) => game.onForcePressPeak(d)
        : null,
    onForcePressUpdate: game is ForcePressDetector
        ? (ForcePressDetails d) => game.onForcePressUpdate(d)
        : null,
    onForcePressEnd: game is ForcePressDetector
        ? (ForcePressDetails d) => game.onForcePressEnd(d)
        : null,

    // Pan
    onPanDown:
        game is PanDetector ? (DragDownDetails d) => game.onPanDown(d) : null,
    onPanStart:
        game is PanDetector ? (DragStartDetails d) => game.onPanStart(d) : null,
    onPanUpdate: game is PanDetector
        ? (DragUpdateDetails d) => game.onPanUpdate(d)
        : null,
    onPanEnd:
        game is PanDetector ? (DragEndDetails d) => game.onPanEnd(d) : null,
    onPanCancel: game is PanDetector ? () => game.onPanCancel() : null,

    // Scales
    onScaleStart: game is ScaleDetector
        ? (ScaleStartDetails d) => game.onScaleStart(d)
        : null,
    onScaleUpdate: game is ScaleDetector
        ? (ScaleUpdateDetails d) => game.onScaleUpdate(d)
        : null,
    onScaleEnd: game is ScaleDetector
        ? (ScaleEndDetails d) => game.onScaleEnd(d)
        : null,

    child: child,
  );
}

Widget _applyMouseDetectors(game, Widget child) {
  return MouseRegion(
    child: Listener(
        child: child,
        onPointerSignal: (event) =>
            game is ScrollDetector && event is PointerScrollEvent
                ? game.onScroll(event)
                : null),
    onHover: game is MouseMovementDetector ? game.onMouseMove : null,
  );
}

class WidgetBuilder {
  Offset offset = Offset.zero;

  Widget build(Game game) {
    Widget widget = Container(
      color: game.backgroundColor(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: EmbeddedGameWidget(game),
      ),
    );

    if (_hasBasicGestureDetectors(game)) {
      widget = _applyBasicGesturesDetectors(game, widget);
    }

    if (_hasAdvancedGesturesDetectors(game)) {
      widget = _applyAdvancedGesturesDetectors(game, widget);
    }

    if (_hasMouseDetectors(game)) {
      widget = _applyMouseDetectors(game, widget);
    }

    return widget;
  }
}

class OverlayGameWidget extends StatefulWidget {
  final Widget gameChild;
  final HasWidgetsOverlay game;

  OverlayGameWidget({Key key, this.gameChild, this.game}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OverlayGameWidgetState();
}

class _OverlayGameWidgetState extends State<OverlayGameWidget> {
  final Map<String, Widget> _overlays = {};

  @override
  void initState() {
    super.initState();
    widget.game.widgetOverlayController.stream.listen((overlay) {
      setState(() {
        if (overlay.widget == null) {
          _overlays.remove(overlay.name);
        } else {
          _overlays[overlay.name] = overlay.widget;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child:
            Stack(children: [widget.gameChild, ..._overlays.values.toList()]));
  }
}

class OverlayWidgetBuilder extends WidgetBuilder {
  OverlayWidgetBuilder();

  @override
  Widget build(Game game) {
    final container = super.build(game);

    return OverlayGameWidget(
        gameChild: container, game: game, key: UniqueKey());
  }
}
