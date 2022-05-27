import 'dart:async';
import 'dart:developer';

import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flame/src/game/game_widget/gestures.dart';
import 'package:flame/src/game/mixins/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
  /// - [GameWidget]
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

  /// The number of `build()` functions currently executing.
  int _buildDepth = 0;

  /// If true, then a fresh build will be scheduled after the current one
  /// completes. This should only be set to true when the [_buildDepth] is
  /// non-zero.
  bool _requiresRebuild = false;

  /// Helper method that arranges to have `_buildDepth > 0` while the [build] is
  /// executing, and then schedules a re-build if [_requiresRebuild] flag was
  /// raised during the build.
  ///
  /// This is needed because our build function invokes user code, which in turn
  /// may change some of the [Game]'s properties which would require the
  /// [GameWidget] to be rebuilt. However, Flutter doesn't allow widgets to be
  /// marked dirty while they are building. So, this method is needed to avoid
  /// such a limitation and ensure that the user code can set [Game]'s
  /// properties freely, and that they will be propagated to the [GameWidget]
  /// at the earliest opportunity.
  Widget _protectedBuild(Widget Function() build) {
    late final Widget result;
    try {
      _buildDepth++;
      result = build();
    } finally {
      _buildDepth--;
    }
    if (_requiresRebuild && _buildDepth == 0) {
      Future.microtask(_onGameStateChange);
    }
    return result;
  }

  void _onGameStateChange() {
    if (_buildDepth > 0) {
      _requiresRebuild = true;
    } else {
      setState(() => _requiresRebuild = false);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.game.addGameStateListener(_onGameStateChange);
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
      oldWidget.game.removeGameStateListener(_onGameStateChange);
      oldWidget.game.onRemove();
      _loaderFuture = null;
      widget.game.addGameStateListener(_onGameStateChange);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.game.removeGameStateListener(_onGameStateChange);
    widget.game.onRemove();
    // If we received a focus node from the user, they are responsible
    // for disposing it
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
  }

  void _checkOverlays(Set<String> overlays) {
    overlays.forEach((overlayKey) {
      assert(
        widget.overlayBuilderMap?.containsKey(overlayKey) ?? false,
        'A non mapped overlay has been added: $overlayKey',
      );
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode focusNode, RawKeyEvent event) {
    final game = widget.game;
    if (game is KeyboardEvents) {
      return game.onKeyEvent(event, RawKeyboard.instance.keysPressed);
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return _protectedBuild(() {
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
                  return _protectedBuild(() {
                    final size = constraints.biggest.toVector2();
                    if (size.isZero()) {
                      return widget.loadingBuilder?.call(context) ??
                          Container();
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
                        return widget.loadingBuilder?.call(context) ??
                            Container();
                      },
                    );
                  });
                },
              ),
            ),
          ),
        ),
      );
    });
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
