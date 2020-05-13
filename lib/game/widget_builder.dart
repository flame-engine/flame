import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

import './gesture_detector.dart' as flame_detector;
import '../gestures.dart';
import 'embedded_game_widget.dart';
import 'game.dart';

bool _hasGestureDetectors(Game game) =>
    game is TapDetector ||
    game is SecondaryTapDetector ||
    game is DoubleTapDetector ||
    game is LongPressDetector ||
    game is VerticalDragDetector ||
    game is HorizontalDragDetector ||
    game is ForcePressDetector ||
    game is PanDetector ||
    game is ScaleDetector ||
    game is MultiTouchTapDetector;

Widget _applyGesturesDetectors(Game game, Widget child) {
  return flame_detector.GestureDetector(
    // Taps
    onTap: game is TapDetector ? () => (game as TapDetector).onTap() : null,
    onTapCancel:
        game is TapDetector ? () => (game as TapDetector).onTapCancel() : null,
    onTapDown: game is TapDetector
        ? (TapDownDetails d) => (game as TapDetector).onTapDown(d)
        : null,
    onTapUp: game is TapDetector
        ? (TapUpDetails d) => (game as TapDetector).onTapUp(d)
        : null,

    // MultiTaps
    onMultiTap: game is MultiTouchTapDetector
        ? (int pointerId) => (game as MultiTouchTapDetector).onTap(pointerId)
        : null,
    onMultiTapCancel: game is MultiTouchTapDetector
        ? (int pointerId) =>
            (game as MultiTouchTapDetector).onTapCancel(pointerId)
        : null,
    onMultiTapDown: game is MultiTouchTapDetector
        ? (int pointerId, TapDownDetails d) =>
            (game as MultiTouchTapDetector).onTapDown(pointerId, d)
        : null,
    onMultiTapUp: game is MultiTouchTapDetector
        ? (int pointerId, TapUpDetails d) =>
            (game as MultiTouchTapDetector).onTapUp(pointerId, d)
        : null,

    // Secondary taps
    onSecondaryTapDown: game is SecondaryTapDetector
        ? (TapDownDetails d) =>
            (game as SecondaryTapDetector).onSecondaryTapDown(d)
        : null,
    onSecondaryTapUp: game is SecondaryTapDetector
        ? (TapUpDetails d) => (game as SecondaryTapDetector).onSecondaryTapUp(d)
        : null,
    onSecondaryTapCancel: game is SecondaryTapDetector
        ? () => (game as SecondaryTapDetector).onSecondaryTapCancel()
        : null,

    // Double tap
    onDoubleTap: game is DoubleTapDetector
        ? () => (game as DoubleTapDetector).onDoubleTap()
        : null,

    // Long presses
    onLongPress: game is LongPressDetector
        ? () => (game as LongPressDetector).onLongPress()
        : null,
    onLongPressStart: game is LongPressDetector
        ? (LongPressStartDetails d) =>
            (game as LongPressDetector).onLongPressStart(d)
        : null,
    onLongPressMoveUpdate: game is LongPressDetector
        ? (LongPressMoveUpdateDetails d) =>
            (game as LongPressDetector).onLongPressMoveUpdate(d)
        : null,
    onLongPressUp: game is LongPressDetector
        ? () => (game as LongPressDetector).onLongPressUp()
        : null,
    onLongPressEnd: game is LongPressDetector
        ? (LongPressEndDetails d) =>
            (game as LongPressDetector).onLongPressEnd(d)
        : null,

    // Vertical drag
    onVerticalDragDown: game is VerticalDragDetector
        ? (DragDownDetails d) =>
            (game as VerticalDragDetector).onVerticalDragDown(d)
        : null,
    onVerticalDragStart: game is VerticalDragDetector
        ? (DragStartDetails d) =>
            (game as VerticalDragDetector).onVerticalDragStart(d)
        : null,
    onVerticalDragUpdate: game is VerticalDragDetector
        ? (DragUpdateDetails d) =>
            (game as VerticalDragDetector).onVerticalDragUpdate(d)
        : null,
    onVerticalDragEnd: game is VerticalDragDetector
        ? (DragEndDetails d) =>
            (game as VerticalDragDetector).onVerticalDragEnd(d)
        : null,
    onVerticalDragCancel: game is VerticalDragDetector
        ? () => (game as VerticalDragDetector).onVerticalDragCancel()
        : null,

    // Horizontal drag
    onHorizontalDragDown: game is HorizontalDragDetector
        ? (DragDownDetails d) =>
            (game as HorizontalDragDetector).onHorizontalDragDown(d)
        : null,
    onHorizontalDragStart: game is HorizontalDragDetector
        ? (DragStartDetails d) =>
            (game as HorizontalDragDetector).onHorizontalDragStart(d)
        : null,
    onHorizontalDragUpdate: game is HorizontalDragDetector
        ? (DragUpdateDetails d) =>
            (game as HorizontalDragDetector).onHorizontalDragUpdate(d)
        : null,
    onHorizontalDragEnd: game is HorizontalDragDetector
        ? (DragEndDetails d) =>
            (game as HorizontalDragDetector).onHorizontalDragEnd(d)
        : null,
    onHorizontalDragCancel: game is HorizontalDragDetector
        ? () => (game as HorizontalDragDetector).onHorizontalDragCancel()
        : null,

    // Force presses
    onForcePressStart: game is ForcePressDetector
        ? (ForcePressDetails d) =>
            (game as ForcePressDetector).onForcePressStart(d)
        : null,
    onForcePressPeak: game is ForcePressDetector
        ? (ForcePressDetails d) =>
            (game as ForcePressDetector).onForcePressPeak(d)
        : null,
    onForcePressUpdate: game is ForcePressDetector
        ? (ForcePressDetails d) =>
            (game as ForcePressDetector).onForcePressUpdate(d)
        : null,
    onForcePressEnd: game is ForcePressDetector
        ? (ForcePressDetails d) =>
            (game as ForcePressDetector).onForcePressEnd(d)
        : null,

    // Pan
    onPanDown: game is PanDetector
        ? (DragDownDetails d) => (game as PanDetector).onPanDown(d)
        : null,
    onPanStart: game is PanDetector
        ? (DragStartDetails d) => (game as PanDetector).onPanStart(d)
        : null,
    onPanUpdate: game is PanDetector
        ? (DragUpdateDetails d) => (game as PanDetector).onPanUpdate(d)
        : null,
    onPanEnd: game is PanDetector
        ? (DragEndDetails d) => (game as PanDetector).onPanEnd(d)
        : null,
    onPanCancel:
        game is PanDetector ? () => (game as PanDetector).onPanCancel() : null,

    // Scales
    onScaleStart: game is ScaleDetector
        ? (ScaleStartDetails d) => (game as ScaleDetector).onScaleStart(d)
        : null,
    onScaleUpdate: game is ScaleDetector
        ? (ScaleUpdateDetails d) => (game as ScaleDetector).onScaleUpdate(d)
        : null,
    onScaleEnd: game is ScaleDetector
        ? (ScaleEndDetails d) => (game as ScaleDetector).onScaleEnd(d)
        : null,

    child: child,
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

    if (_hasGestureDetectors(game)) {
      widget = _applyGesturesDetectors(game, widget);
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
