import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

import 'game.dart';
import '../gestures.dart';
import '../components/mixins/tapable.dart';
import 'game_render_box.dart';

typedef GameLoadingWidgetBuilder = Widget Function(
  BuildContext,
  bool error,
);

/// A [StatefulWidget] that is in charge of attaching a [Game] instance into the flutter tree
///
class GameWidget<T extends Game> extends StatefulWidget {
  /// The game instance in which this widget will render
  final T game;

  /// The text direction to be used in text elements in a game.
  final TextDirection textDirection;

  /// Builder to provide a widget tree to be built whilst the [Future] provided
  /// via [Game.onLoad] is not resolved.
  final GameLoadingWidgetBuilder loadingBuilder;

  /// Builder to provide a widget tree to be built between the game elements and
  /// the background color provided via [Game.backgroundColor]
  final WidgetBuilder backgroundBuilder;

  /// A map to show widgets overlay.
  ///
  /// See also:
  /// - [new GameWidget]
  /// - [Game.overlays]
  final Map<String, WidgetBuilder> overlayBuilderMap;

  /// Renders a [game] in a flutter widget tree.
  ///
  /// Ex:
  /// ```
  /// ...
  /// Widget build(BuildContext  context) {
  ///   return GameWidget(
  ///     game: MyGameClass(),
  ///   )
  /// }
  /// ...
  /// ```
  ///
  /// It is also possible to render layers of widgets over the game surface with widget subtrees.
  ///
  /// To do that a [overlayBuilderMap] should be provided. The visibility of
  /// these overlays are controlled by [Game.overlays] property
  ///
  /// Ex:
  /// ```
  /// ...
  ///
  /// final game = MyGame();
  ///
  /// Widget build(BuildContext  context) {
  ///   return GameWidget(
  ///     game: game,
  ///     overlayBuilderMap: {
  ///       "PauseMenu": (ctx) {
  ///         return Text("A pause menu");
  ///       },
  ///     },
  ///   )
  /// }
  /// ...
  /// game.overlays.add("PauseMenu");
  /// ```
  const GameWidget({
    Key key,
    this.game,
    this.textDirection,
    this.loadingBuilder,
    this.backgroundBuilder,
    this.overlayBuilderMap,
  }) : super(key: key);

  /// Renders a [game] in a flutter widget tree alongside widgets overlays.
  ///
  /// To use overlays, the game subclass has to be mixed with [HasWidgetsOverlay],

  @override
  _GameWidgetState createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  Set<String> activeOverlays = {};

  @override
  void initState() {
    super.initState();
    addOverlaysListener(widget.game);
    loadingFuture = widget.game.onLoad();
  }

  @override
  void didUpdateWidget(covariant GameWidget<Game> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.game != widget.game) {
      removeOverlaysListener(oldWidget.game);
      addOverlaysListener(widget.game);
    }
    loadingFuture = widget.game.onLoad();
  }

  @override
  void dispose() {
    super.dispose();
    removeOverlaysListener(widget.game);
  }

  // widget overlay stuff
  void addOverlaysListener(Game game) {
    widget.game.overlays.addListener(onChangeActiveOverlays);
    activeOverlays = widget.game.overlays.value;
  }

  void removeOverlaysListener(Game game) {
    game.overlays.removeListener(onChangeActiveOverlays);
  }

  void onChangeActiveOverlays() {
    widget.game.overlays.value.forEach((overlayKey) {
      assert(widget.overlayBuilderMap.containsKey(overlayKey),
          "A non mapped overlay has been added: $overlayKey");
    });
    setState(() {
      activeOverlays = widget.game.overlays.value;
    });
  }

  // loading future
  Future<void> loadingFuture;

  @override
  Widget build(BuildContext context) {
    Widget internalGameWidget = _GameRenderObjectWidget(widget.game);

    final hasBasicDetectors = _hasBasicGestureDetectors(widget.game);
    final hasAdvancedDetectors = _hasAdvancedGesturesDetectors(widget.game);

    assert(
      !(hasBasicDetectors && hasAdvancedDetectors),
      """
        WARNING: Both Advanced and Basic detectors detected.
        Advanced detectors will override basic detectors and the later will not receive events
      """,
    );

    if (hasBasicDetectors) {
      internalGameWidget = _applyBasicGesturesDetectors(
        widget.game,
        internalGameWidget,
      );
    } else if (hasAdvancedDetectors) {
      internalGameWidget = _applyAdvancedGesturesDetectors(
        widget.game,
        internalGameWidget,
      );
    }

    if (_hasMouseDetectors(widget.game)) {
      internalGameWidget = _applyMouseDetectors(
        widget.game,
        internalGameWidget,
      );
    }

    List<Widget> stackedWidgets = [internalGameWidget];
    stackedWidgets = _addBackground(context, stackedWidgets);
    stackedWidgets = _addOverlays(context, stackedWidgets);
    return Directionality(
      textDirection: widget.textDirection ??
          Directionality.maybeOf(context) ??
          TextDirection.ltr,
      child: Container(
        color: widget.game.backgroundColor(),
        child: FutureBuilder(
          future: loadingFuture,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(children: stackedWidgets);
            }
            return widget.loadingBuilder != null
                ? widget.loadingBuilder(context, snapshot.hasError)
                : Container();
          },
        ),
      ),
    );
  }

  List<Widget> _addBackground(BuildContext context, List<Widget> stackWidgets) {
    if (widget.backgroundBuilder == null) {
      return stackWidgets;
    }
    final backgroundContent = KeyedSubtree(
      key: ValueKey(widget.game),
      child: widget.backgroundBuilder(context),
    );
    stackWidgets.insert(0, backgroundContent);
    return stackWidgets;
  }

  List<Widget> _addOverlays(BuildContext context, List<Widget> stackWidgets) {
    if (widget.overlayBuilderMap == null) {
      return stackWidgets;
    }
    final widgets = activeOverlays.map((String overlayKey) {
      final builder = widget.overlayBuilderMap[overlayKey];
      return KeyedSubtree(
        key: ValueKey(overlayKey),
        child: builder(context),
      );
    });
    stackWidgets.addAll(widgets);
    return stackWidgets;
  }
}

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

Widget _applyBasicGesturesDetectors(Game game, Widget child) {
  return GestureDetector(
    key: const ObjectKey("BasicGesturesDetector"),
    behavior: HitTestBehavior.opaque,

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

Widget _applyAdvancedGesturesDetectors(Game game, Widget child) {
  final Map<Type, GestureRecognizerFactory> gestures = {};

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
    child: child,
  );
}

Widget _applyMouseDetectors(Game game, Widget child) {
  return MouseRegion(
    child: Listener(
      child: child,
      onPointerSignal: (event) =>
          game is ScrollDetector && event is PointerScrollEvent
              ? game.onScroll(event)
              : null,
    ),
    onHover: game is MouseMovementDetector ? game.onMouseMove : null,
  );
}

class _GenericTapEventHandler {
  void Function(int pointerId) onTap;
  void Function(int pointerId) onTapCancel;
  void Function(int pointerId, TapDownDetails details) onTapDown;
  void Function(int pointerId, TapUpDetails details) onTapUp;
}

class _GameRenderObjectWidget extends LeafRenderObjectWidget {
  final Game game;

  _GameRenderObjectWidget(this.game);

  @override
  RenderBox createRenderObject(BuildContext context) {
    return RenderConstrainedBox(
      child: GameRenderBox(context, game),
      additionalConstraints: const BoxConstraints.expand(),
    );
  }
}
