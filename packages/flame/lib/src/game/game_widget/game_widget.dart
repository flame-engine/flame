import 'dart:async';

import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flame/src/game/game_widget/gesture_detector_builder.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The **GameWidget** is a Flutter widget which is used to insert a [Game]
/// instance into the Flutter widget tree.
///
/// The `GameWidget` is sufficiently feature-rich to run as the root of your
/// Flutter application. Thus, the simplest way to use `GameWidget` is like
/// this:
/// ```dart
/// void main() {
///   runApp(
///     GameWidget(game: MyGame()),
///   );
/// }
/// ```
///
/// At the same time, `GameWidget` is a regular Flutter widget, and can be
/// inserted arbitrarily deep into the widget tree, including the possibility
/// of having multiple `GameWidget`s within a single app.
///
/// The layout behavior of this widget is that it will expand to fill all
/// available space. Thus, when used as a root widget it will make the app
/// full-screen. Inside any other layout widget it will take as much space as
/// possible.
///
/// In addition to hosting a [Game] instance, the `GameWidget` also provides
/// some structural support, with the following features:
/// - [loadingBuilder] to display something while the game is loading;
/// - [errorBuilder] which will be shows if the game throws an error;
/// - [backgroundBuilder] to draw some decoration behind the game;
/// - [overlayBuilderMap] to draw one or more widgets on top of the game.
///
/// It should be noted that `GameWidget` does not clip the content of its
/// canvas, which means the game can potentially draw outside of its boundaries
/// (not always, depending on which camera is used). If this is not desired,
/// then consider wrapping the widget in Flutter's [ClipRect].
class GameWidget<T extends Game> extends StatefulWidget {
  /// Renders the provided [game] instance.
  GameWidget({
    required T this.game,
    this.textDirection,
    this.loadingBuilder,
    this.errorBuilder,
    this.backgroundBuilder,
    this.overlayBuilderMap,
    this.initialActiveOverlays,
    this.focusNode,
    this.autofocus = true,
    this.mouseCursor,
    this.addRepaintBoundary = true,
    super.key,
  }) : gameFactory = null {
    _initializeGame(game!);
  }

  /// A `GameWidget` which will create and own a `Game` instance, using the
  /// provided [gameFactory].
  ///
  /// This constructor can be useful when you want to put `GameWidget` into
  /// another widget, but would like to avoid the need to store the game's
  /// instance yourself. For example:
  /// ```dart
  /// class MyWidget extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return Container(
  ///       padding: EdgeInsets.all(20),
  ///       child: GameWidget.controlled(
  ///         gameFactory: MyGame.new,
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  const GameWidget.controlled({
    required GameFactory<T> this.gameFactory,
    this.textDirection,
    this.loadingBuilder,
    this.errorBuilder,
    this.backgroundBuilder,
    this.overlayBuilderMap,
    this.initialActiveOverlays,
    this.focusNode,
    this.autofocus = true,
    this.mouseCursor,
    this.addRepaintBoundary = true,
    super.key,
  }) : game = null;

  /// The game instance which this widget will render, if it was provided with
  /// the default constructor. Otherwise, if the [GameWidget.controlled]
  /// constructor was used, this will always be `null`.
  final T? game;

  /// A function that creates a [Game] that this widget will render.
  final GameFactory<T>? gameFactory;

  /// The text direction to be used in text elements in a game.
  final TextDirection? textDirection;

  /// Builder to provide a widget which will be displayed while the game is
  /// loading. By default this is an empty `Container`.
  final GameLoadingWidgetBuilder? loadingBuilder;

  /// If set, errors during the game loading will be caught and this widget
  /// will be shown. If not provided, errors are propagated normally.
  final GameErrorWidgetBuilder? errorBuilder;

  /// Builder to provide a widget tree to be built between the game elements and
  /// the background color provided via [Game.backgroundColor].
  final WidgetBuilder? backgroundBuilder;

  /// A collection of widgets that can be displayed over the game's surface.
  /// These widgets can be turned on-and-off dynamically from within the game
  /// via the [Game.overlays] property.
  ///
  /// ```dart
  /// void main() {
  ///   runApp(
  ///     GameWidget(
  ///       game: MyGame(),
  ///       overlayBuilderMap: {
  ///         'PauseMenu': (context, game) {
  ///           return Container(
  ///             color: const Color(0xFF000000),
  ///             child: Text('A pause menu'),
  ///           );
  ///         },
  ///       },
  ///     ),
  ///   );
  /// }
  /// ```
  final Map<String, OverlayWidgetBuilder<T>>? overlayBuilderMap;

  /// The list of overlays that will be shown when the game starts (but after
  /// it was loaded).
  final List<String>? initialActiveOverlays;

  /// The [FocusNode] to control the games focus to receive event inputs.
  /// If omitted, defaults to an internally controlled focus node.
  final FocusNode? focusNode;

  /// Whether the [focusNode] requests focus once the game is mounted.
  /// Defaults to true.
  final bool autofocus;

  /// The shape of the mouse cursor when it is hovering over the game canvas.
  /// This property can be changed dynamically via [Game.mouseCursor].
  final MouseCursor? mouseCursor;

  /// Whether the game should assume the behavior of a [RepaintBoundary],
  /// defaults to `true`.
  final bool addRepaintBoundary;

  /// Renders a [game] in a flutter widget tree alongside widgets overlays.
  ///
  /// To use overlays, the game subclass has to be mixed with HasWidgetsOverlay.
  @override
  GameWidgetState<T> createState() => GameWidgetState<T>();

  void _initializeGame(T game) {
    if (mouseCursor != null) {
      game.mouseCursor = mouseCursor!;
    }
    if (overlayBuilderMap != null) {
      for (final kv in overlayBuilderMap!.entries) {
        game.overlays.addEntry(
          kv.key,
          (ctx, game) => kv.value(ctx, game as T),
        );
      }
    }
    if (initialActiveOverlays != null) {
      game.overlays.addAll(initialActiveOverlays!);
    }
  }
}

class GameWidgetState<T extends Game> extends State<GameWidget<T>> {
  late T currentGame;

  Future<void> get loaderFuture => _loaderFuture ??= (() async {
    final game = currentGame;
    assert(game.hasLayout);
    await game.load();
    game.mount();
    if (!game.paused) {
      game.update(0);
    }
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

  void initCurrentGame() {
    if (widget.game == null) {
      currentGame = widget.gameFactory!.call();
      widget._initializeGame(currentGame);
    } else {
      currentGame = widget.game!;
    }
    initGameStateListener(currentGame, _onGameStateChange);
    _loaderFuture = null;
  }

  /// Visible for testing for
  /// https://github.com/flame-engine/flame/issues/2771.
  @visibleForTesting
  static void initGameStateListener(
    Game currentGame,
    void Function() onGameStateChange,
  ) {
    currentGame.addGameStateListener(onGameStateChange);

    // See https://github.com/flame-engine/flame/issues/2771
    // for why we aren't using [WidgetsBinding.instance.lifecycleState].
    currentGame.lifecycleStateChange(AppLifecycleState.resumed);
  }

  /// [disposeCurrentGame] is called by two flutter events - `didUpdateWidget`
  /// and `dispose`.  When the parameter [callGameOnDispose] is true, the
  /// `currentGame`'s `onDispose` method will be called; otherwise, it will not.
  void disposeCurrentGame({bool callGameOnDispose = false}) {
    currentGame.removeGameStateListener(_onGameStateChange);
    currentGame.lifecycleStateChange(AppLifecycleState.paused);
    currentGame.finalizeRemoval();
    if (callGameOnDispose) {
      currentGame.onDispose();
    }
  }

  @override
  void initState() {
    super.initState();
    initCurrentGame();
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.autofocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(GameWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.game != widget.game) {
      disposeCurrentGame();
      initCurrentGame();
    }
  }

  @override
  void dispose() {
    disposeCurrentGame(callGameOnDispose: true);
    // If we received a focus node from the user, they are responsible
    // for disposing it
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode focusNode, KeyEvent event) {
    final game = currentGame;

    if (!_focusNode.hasPrimaryFocus) {
      return KeyEventResult.ignored;
    }

    if (game is KeyboardEvents) {
      return game.onKeyEvent(
        event,
        HardwareKeyboard.instance.logicalKeysPressed,
      );
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return _protectedBuild(() {
      Widget? internalGameWidget = RenderGameWidget(
        game: currentGame,
        addRepaintBoundary: widget.addRepaintBoundary,
      );

      assert(
        !(currentGame is MultiTouchDragDetector && currentGame is PanDetector),
        'WARNING: Both MultiTouchDragDetector and a PanDetector detected. '
        'The MultiTouchDragDetector will override the PanDetector and it will '
        'not receive events',
      );

      internalGameWidget = currentGame.gestureDetectors.build(
        internalGameWidget,
      );

      if (hasMouseDetectors(currentGame)) {
        internalGameWidget = applyMouseDetectors(
          currentGame,
          internalGameWidget,
        );
      }

      final stackedWidgets = [internalGameWidget];
      _addBackground(context, stackedWidgets);
      _addOverlays(context, stackedWidgets);

      // We can use Directionality.maybeOf when that method lands on stable
      final textDir = widget.textDirection ?? TextDirection.ltr;

      return FocusScope(
        child: Focus(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          descendantsAreFocusable: true,
          onKeyEvent: _handleKeyEvent,
          child: MouseRegion(
            cursor: currentGame.mouseCursor,
            child: Directionality(
              textDirection: textDir,
              child: ColoredBox(
                color: currentGame.backgroundColor(),
                child: LayoutBuilder(
                  builder: (_, BoxConstraints constraints) {
                    return _protectedBuild(() {
                      final size = constraints.biggest.toVector2();
                      if (size.isZero()) {
                        return widget.loadingBuilder?.call(context) ??
                            Container();
                      }
                      currentGame.onGameResize(size);
                      // This should only be called if the game has already been
                      // loaded (in the case of resizing for example), since
                      // update otherwise should be called after onMount.
                      if (!currentGame.paused && currentGame.isAttached) {
                        currentGame.update(0);
                      }
                      return FutureBuilder(
                        future: loaderFuture,
                        builder: (_, snapshot) {
                          if (snapshot.hasError) {
                            final errorBuilder = widget.errorBuilder;
                            if (errorBuilder == null) {
                              throw Error.throwWithStackTrace(
                                snapshot.error!,
                                snapshot.stackTrace!,
                              );
                            } else {
                              return errorBuilder(context, snapshot.error!);
                            }
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Stack(children: stackedWidgets);
                          }

                          return widget.loadingBuilder?.call(context) ??
                              const SizedBox.expand();
                        },
                      );
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _addBackground(BuildContext context, List<Widget> stackWidgets) {
    if (widget.backgroundBuilder != null) {
      final backgroundContent = KeyedSubtree(
        key: ValueKey(widget.game),
        child: widget.backgroundBuilder!(context),
      );
      stackWidgets.insert(0, backgroundContent);
    }
  }

  void _addOverlays(BuildContext context, List<Widget> stackWidgets) {
    stackWidgets.addAll(
      currentGame.overlays.buildCurrentOverlayWidgets(context),
    );
  }
}

typedef GameLoadingWidgetBuilder = Widget Function(BuildContext);

typedef GameErrorWidgetBuilder = Widget Function(BuildContext, Object error);

typedef OverlayWidgetBuilder<T extends Game> =
    Widget Function(
      BuildContext context,
      T game,
    );

typedef GameFactory<T extends Game> = T Function();
