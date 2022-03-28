import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../extensions.dart';
import '../../../input.dart';
import '../game_render_box.dart';
import '../mixins/game.dart';
import 'gestures.dart';

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

/// A [StatefulWidget] that is in charge of attaching a [Game] instance into the
/// Flutter tree.
class GameWidget<T extends Game> extends StatefulWidget {
  /// The game instance in which this widget will render
  final T game;

  /// The text direction to be used in text elements in a game.
  final TextDirection? textDirection;

  /// Builder to provide a widget tree to be built while the Game's [Future]
  /// provided via `Game.onLoad` and `Game.onMount` is not resolved.
  /// By default this is an empty Container().
  final GameLoadingWidgetBuilder? loadingBuilder;

  /// If set, errors during the onLoad method will not be thrown
  /// but instead this widget will be shown. If not provided, errors are
  /// propagated up.
  final GameErrorWidgetBuilder? errorBuilder;

  /// Builder to provide a widget tree to be built between the game elements and
  /// the background color provided via [Game.backgroundColor].
  final WidgetBuilder? backgroundBuilder;

  /// A map to show widgets overlay.
  ///
  /// See also:
  /// - [new GameWidget]
  /// - [Game.overlays]
  final Map<String, OverlayWidgetBuilder<T>>? overlayBuilderMap;

  /// The [FocusNode] to control the games focus to receive event inputs.
  /// If omitted, defaults to an internally controlled focus node.
  final FocusNode? focusNode;

  /// Whether the [focusNode] requests focus once the game is mounted.
  /// Defaults to true.
  final bool autofocus;

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
  /// It is also possible to render layers of widgets over the game surface with
  /// widget subtrees.
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
  ///       'PauseMenu': (ctx, game) {
  ///         return Text('A pause menu');
  ///       },
  ///     },
  ///   )
  /// }
  /// ...
  /// game.overlays.add('PauseMenu');
  /// ```
  GameWidget({
    Key? key,
    required this.game,
    this.textDirection,
    this.loadingBuilder,
    this.errorBuilder,
    this.backgroundBuilder,
    this.overlayBuilderMap,
    List<String>? initialActiveOverlays,
    this.focusNode,
    this.autofocus = true,
    MouseCursor? mouseCursor,
  }) : super(key: key) {
    if (mouseCursor != null) {
      game.mouseCursor = mouseCursor;
    }
    if (initialActiveOverlays != null) {
      initialActiveOverlays.forEach(game.overlays.add);
    }
  }

  /// Renders a [game] in a flutter widget tree alongside widgets overlays.
  ///
  /// To use overlays, the game subclass has to be mixed with HasWidgetsOverlay.
  @override
  _GameWidgetState<T> createState() => _GameWidgetState<T>();
}

class _GameWidgetState<T extends Game> extends State<GameWidget<T>> {
  Future<void> get loaderFuture => _loaderFuture ??= (() async {
        assert(widget.game.hasLayout);
        final onLoad = widget.game.onLoadFuture;
        if (onLoad != null) {
          await onLoad;
        }
        widget.game.onMount();
      })();

  Future<void>? _loaderFuture;

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    widget.game.gameStateListener = () => setState(() {});
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.autofocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(GameWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.game != widget.game) {
      // Reset the loaderFuture so that onMount will run again
      // (onLoad is still cached).
      oldWidget.game.onRemove();
      _loaderFuture = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.game.onRemove();
    // If we received a focus node from the user, they are responsible
    // for disposing it
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
  }

  //#region Widget overlay methods

  void _checkOverlays(Set<String> overlays) {
    overlays.forEach((overlayKey) {
      assert(
        widget.overlayBuilderMap?.containsKey(overlayKey) ?? false,
        'A non mapped overlay has been added: $overlayKey',
      );
    });
  }

  //#endregion

  KeyEventResult _handleKeyEvent(FocusNode focusNode, RawKeyEvent event) {
    final game = widget.game;
    if (game is KeyboardEvents) {
      return game.onKeyEvent(event, RawKeyboard.instance.keysPressed);
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    Widget internalGameWidget = _GameRenderObjectWidget(game);

    _checkOverlays(widget.game.overlays.value);
    assert(
      !(game is MultiTouchDragDetector && game is PanDetector),
      'WARNING: Both MultiTouchDragDetector and a PanDetector detected. '
      'The MultiTouchDragDetector will override the PanDetector and it will '
      'not receive events',
    );

    if (hasBasicGestureDetectors(game)) {
      internalGameWidget = applyBasicGesturesDetectors(
        game,
        internalGameWidget,
      );
    }

    if (hasAdvancedGestureDetectors(game)) {
      internalGameWidget = applyAdvancedGesturesDetectors(
        game,
        internalGameWidget,
      );
    }

    if (hasMouseDetectors(game)) {
      internalGameWidget = applyMouseDetectors(
        game,
        internalGameWidget,
      );
    }

    final stackedWidgets = [internalGameWidget];
    _addBackground(context, stackedWidgets);
    _addOverlays(context, stackedWidgets);

    // We can use Directionality.maybeOf when that method lands on stable
    final textDir = widget.textDirection ?? TextDirection.ltr;

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKey: _handleKeyEvent,
      child: MouseRegion(
        cursor: widget.game.mouseCursor,
        child: Directionality(
          textDirection: textDir,
          child: Container(
            color: game.backgroundColor(),
            child: LayoutBuilder(
              builder: (_, BoxConstraints constraints) {
                final size = constraints.biggest.toVector2();
                if (size.isZero()) {
                  return widget.loadingBuilder?.call(context) ?? Container();
                }
                game.onGameResize(size);
                return FutureBuilder(
                  future: loaderFuture,
                  builder: (_, snapshot) {
                    if (snapshot.hasError) {
                      final errorBuilder = widget.errorBuilder;
                      if (errorBuilder == null) {
                        // @Since('2.16')
                        // throw Error.throwWithStackTrace(
                        //   snapshot.error!,
                        //   snapshot.stackTrace,
                        // )
                        log(
                          'Error while loading Game widget',
                          error: snapshot.error,
                          stackTrace: snapshot.stackTrace,
                        );
                        throw snapshot.error!;
                      } else {
                        return errorBuilder(context, snapshot.error!);
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
    final widgets = widget.game.overlays.value.map((String overlayKey) {
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

class _GameRenderObjectWidget extends LeafRenderObjectWidget {
  final Game game;

  const _GameRenderObjectWidget(this.game);

  @override
  RenderBox createRenderObject(BuildContext context) {
    return GameRenderBox(context, game);
  }

  @override
  void updateRenderObject(BuildContext context, GameRenderBox renderObject) {
    renderObject.game = game;
  }
}
