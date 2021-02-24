import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

import 'game.dart';
import '../gestures.dart';
import '../components/mixins/draggable.dart';
import '../components/mixins/tapable.dart';
import '../extensions/size.dart';
import 'game_render_box.dart';

typedef GameLoadingWidgetBuilder = Widget Function(
  BuildContext,
);

typedef GameErrorWidgetBuilder = Widget Function(
  BuildContext,
  Object error,
);

typedef OverlayWidgetBuilder<T extends Game> = Widget Function(
  BuildContext context,
  T game,
);

/// A [StatefulWidget] that is in charge of attaching a [Game] instance into the flutter tree
///
class GameWidget<T extends Game> extends StatefulWidget {
  /// The game instance in which this widget will render
  final T game;

  /// The text direction to be used in text elements in a game.
  final TextDirection? textDirection;

  /// Builder to provide a widget tree to be built whilst the [Future] provided
  /// via [Game.onLoad] is not resolved. By default this is an empty Container().
  final GameLoadingWidgetBuilder? loadingBuilder;

  /// If set, errors during the onLoad method will not be thrown
  /// but instead this widget will be shown. If not provided, errors are
  /// propagated up.
  final GameErrorWidgetBuilder? errorBuilder;

  /// Builder to provide a widget tree to be built between the game elements and
  /// the background color provided via [Game.backgroundColor]
  final WidgetBuilder? backgroundBuilder;

  /// A map to show widgets overlay.
  ///
  /// See also:
  /// - [new GameWidget]
  /// - [Game.overlays]
  final Map<String, OverlayWidgetBuilder<T>>? overlayBuilderMap;

  /// A List of the initially active overlays, this is used only on the first build of the widget.
  /// To control the overlays that are active use [Game.overlays]
  ///
  /// See also:
  /// - [new GameWidget]
  /// - [Game.overlays]
  final List<String>? initialActiveOverlays;

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
    Key? key,
    required this.game,
    this.textDirection,
    this.loadingBuilder,
    this.errorBuilder,
    this.backgroundBuilder,
    this.overlayBuilderMap,
    this.initialActiveOverlays,
  }) : super(key: key);

  /// Renders a [game] in a flutter widget tree alongside widgets overlays.
  ///
  /// To use overlays, the game subclass has to be mixed with [HasWidgetsOverlay],

  @override
  _GameWidgetState<T> createState() => _GameWidgetState<T>();
}

class _GameWidgetState<T extends Game> extends State<GameWidget<T>> {
  Set<String> initialActiveOverlays = {};

  Future<void>? _gameLoaderFuture;
  Future<void> get _gameLoaderFutureCache =>
      _gameLoaderFuture ?? (_gameLoaderFuture = widget.game.onLoad());

  @override
  void initState() {
    super.initState();

    // Add the initial overlays
    _initActiveOverlays();

    addOverlaysListener(widget.game);
  }

  void _initActiveOverlays() {
    if (widget.initialActiveOverlays == null) {
      return;
    }
    _checkOverlays(widget.initialActiveOverlays!.toSet());
    widget.initialActiveOverlays!.forEach((key) {
      widget.game.overlays.add(key);
    });
  }

  @override
  void didUpdateWidget(GameWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.game != widget.game) {
      removeOverlaysListener(oldWidget.game);

      // Reset the overlays
      _initActiveOverlays();
      addOverlaysListener(widget.game);

      // Reset the loader future
      _gameLoaderFuture = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    removeOverlaysListener(widget.game);
  }

  // widget overlay stuff
  void addOverlaysListener(T game) {
    widget.game.overlays.addListener(onChangeActiveOverlays);
    initialActiveOverlays = widget.game.overlays.value;
  }

  void removeOverlaysListener(T game) {
    game.overlays.removeListener(onChangeActiveOverlays);
  }

  void _checkOverlays(Set<String> overlays) {
    overlays.forEach((overlayKey) {
      assert(
        widget.overlayBuilderMap?.containsKey(overlayKey) ?? false,
        "A non mapped overlay has been added: $overlayKey",
      );
    });
  }

  void onChangeActiveOverlays() {
    _checkOverlays(widget.game.overlays.value);
    setState(() {
      initialActiveOverlays = widget.game.overlays.value;
    });
  }

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

    final stackedWidgets = [internalGameWidget];
    _addBackground(context, stackedWidgets);
    _addOverlays(context, stackedWidgets);

    // We can use Directionality.maybeOf when that method lands on stable
    final textDir = widget.textDirection ?? TextDirection.ltr;

    return Directionality(
      textDirection: textDir,
      child: Container(
        color: widget.game.backgroundColor(),
        child: LayoutBuilder(
          builder: (_, BoxConstraints constraints) {
            widget.game.onResize(constraints.biggest.toVector2());
            return FutureBuilder(
              future: _gameLoaderFutureCache,
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  if (widget.errorBuilder == null) {
                    throw snapshot.error!;
                  } else {
                    return widget.errorBuilder!(context, snapshot.error!);
                  }
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(children: stackedWidgets);
                }
                return widget.loadingBuilder?.call(context) ?? Container();
              },
            );
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
      child: widget.backgroundBuilder!(context),
    );
    stackWidgets.insert(0, backgroundContent);
    return stackWidgets;
  }

  List<Widget> _addOverlays(BuildContext context, List<Widget> stackWidgets) {
    if (widget.overlayBuilderMap == null) {
      return stackWidgets;
    }
    final widgets = initialActiveOverlays.map((String overlayKey) {
      final builder = widget.overlayBuilderMap![overlayKey]!;
      return KeyedSubtree(
        key: ValueKey(overlayKey),
        child: builder(context, widget.game),
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
    game is HasTapableComponents ||
    game is HasDraggableComponents;

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
  final List<_GenericTapEventHandler> tapHandlers = [];
  final List<_GenericDragEventHandler> dragHandlers = [];

  if (game is HasTapableComponents) {
    tapHandlers.add(_GenericTapEventHandler()
      ..onTapDown = game.onTapDown
      ..onTapUp = game.onTapUp
      ..onTapCancel = game.onTapCancel);
  }

  if (game is MultiTouchTapDetector) {
    tapHandlers.add(_GenericTapEventHandler()
      ..onTapDown = game.onTapDown
      ..onTapUp = game.onTapUp
      ..onTapCancel = game.onTapCancel);
  }

  if (game is HasDraggableComponents) {
    dragHandlers
        .add(_GenericDragEventHandler()..onReceiveDrag = game.onReceiveDrag);
  }

  if (game is MultiTouchDragDetector) {
    dragHandlers
        .add(_GenericDragEventHandler()..onReceiveDrag = game.onReceiveDrag);
  }

  if (tapHandlers.isNotEmpty) {
    gestures[MultiTapGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<MultiTapGestureRecognizer>(
      () => MultiTapGestureRecognizer(),
      (MultiTapGestureRecognizer instance) {
        instance.onTapDown = (pointerId, d) =>
            tapHandlers.forEach((h) => h.onTapDown?.call(pointerId, d));
        instance.onTapUp = (pointerId, d) =>
            tapHandlers.forEach((h) => h.onTapUp?.call(pointerId, d));
        instance.onTapCancel = (pointerId) =>
            tapHandlers.forEach((h) => h.onTapCancel?.call(pointerId));
        instance.onTap =
            (pointerId) => tapHandlers.forEach((h) => h.onTap?.call(pointerId));
      },
    );
  }

  if (dragHandlers.isNotEmpty) {
    gestures[ImmediateMultiDragGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<
            ImmediateMultiDragGestureRecognizer>(
      () => ImmediateMultiDragGestureRecognizer(),
      (MultiDragGestureRecognizer instance) {
        instance
          ..onStart = (Offset o) {
            // Note that padding or margin isn't taken into account here
            final drag = DragEvent(o);
            dragHandlers.forEach((h) => h.onReceiveDrag?.call(drag));
            return drag;
          };
      },
    );
  }

  return RawGestureDetector(
    gestures: gestures,
    behavior: HitTestBehavior.opaque,
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
  void Function(int pointerId)? onTap;
  void Function(int pointerId)? onTapCancel;
  void Function(int pointerId, TapDownDetails details)? onTapDown;
  void Function(int pointerId, TapUpDetails details)? onTapUp;
}

class _GenericDragEventHandler {
  void Function(DragEvent details)? onReceiveDrag;
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
