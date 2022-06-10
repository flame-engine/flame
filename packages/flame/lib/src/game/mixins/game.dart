import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flame/src/game/projector.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// This gives access to a low-level game API, to not build everything from a
/// low level `FlameGame` should be used.
///
/// Add this mixin to your game class and implement the [update] and [render]
/// methods to use it in a `GameWidget`.
/// Flame will deal with calling these methods properly when the game's widget
/// is rendered.
mixin Game {
  final images = Images();
  final assets = AssetsCache();

  /// This should update the state of the game.
  void update(double dt);

  /// This should render the game.
  void render(Canvas canvas);

  /// Just a reference back to the render box that is kept up to date by the
  /// engine.
  GameRenderBox get renderBox => _gameRenderBox!;
  GameRenderBox? _gameRenderBox;

  /// Currently attached build context. Can be null if not attached.
  BuildContext? get buildContext => _gameRenderBox?.buildContext;

  /// Whether the game widget was attached to the Flutter tree.
  bool get isAttached => buildContext != null;

  /// Current size of the game as provided by the framework; it will be null if
  /// layout has not been computed yet.
  ///
  /// Use [size] and [hasLayout] for safe access.
  Vector2? _size;

  /// This variable ensures that Game's [onLoad] is called no more than once.
  late final Future<void>? _onLoadFuture = onLoad();

  bool _debugOnLoadStarted = false;

  @internal
  Future<void>? get onLoadFuture {
    assert(
      () {
        _debugOnLoadStarted = true;
        return true;
      }(),
    );
    return _onLoadFuture;
  }

  /// To be used for tests that needs to evaluate the game after it has been
  /// loaded by the game widget.
  @visibleForTesting
  Future<void>? toBeLoaded() {
    assert(
      _debugOnLoadStarted,
      'Make sure the game has passed to a mounted '
      'GameWidget before calling toBeLoaded',
    );
    return _onLoadFuture;
  }

  /// Current game viewport size, updated every resize via the [onGameResize]
  /// method hook.
  Vector2 get size {
    assertHasLayout();
    return _size!;
  }

  Vector2 get canvasSize {
    assertHasLayout();
    return _size!;
  }

  /// Indicates if this game instance is connected to a GameWidget that is live
  /// in the flutter widget tree.
  /// Once this is true, the game is ready to have its size used or in the case
  /// of a FlameGame, to receive components.
  bool get hasLayout => _size != null;

  /// Returns the game background color.
  /// By default it will return a black color.
  /// It cannot be changed at runtime, because the game widget does not get
  /// rebuild when this value changes.
  Color backgroundColor() => const Color(0xFF000000);

  /// This is the resize hook; every time the game widget is resized, this hook
  /// is called.
  ///
  /// The default implementation just sets the new size on the size field
  @mustCallSuper
  void onGameResize(Vector2 size) {
    _size = (_size ?? Vector2.zero())..setFrom(size);
  }

  @protected
  void assertHasLayout() {
    assert(
      hasLayout,
      '"size" is not ready yet. Did you try to access it on the Game '
      'constructor? Use the "onLoad" method instead.',
    );
  }

  /// This is the lifecycle state change hook; every time the game is resumed,
  /// paused or suspended, this is called.
  ///
  /// The default implementation does nothing; override to use the hook.
  /// Check [AppLifecycleState] for details about the events received.
  void lifecycleStateChange(AppLifecycleState state) {}

  /// Method to perform late initialization of the [Game] class.
  ///
  /// Usually, this method is the main place where you initialize your [Game]
  /// class. This has several advantages over the traditional constructor:
  ///   - this method can be `async`;
  ///   - it is invoked when the size of the game widget is already known.
  ///
  /// The default implementation returns `null`, indicating that there is no
  /// need to await anything. When overriding this method, you have a choice
  /// whether to create a regular or async function.
  ///
  /// If you need an async [onLoad], then make your override return non-nullable
  /// `Future<void>`:
  /// ```dart
  /// @override
  /// Future<void> onLoad() async {
  ///   // your code here
  /// }
  /// ```
  ///
  /// Alternatively, if your [onLoad] function doesn't use any `await`ing, then
  /// you can declare it as a regular method and then return `null`:
  /// ```dart
  /// @override
  /// Future<void>? onLoad() {
  ///   // your code here
  ///   return null;
  /// }
  /// ```
  ///
  /// The engine ensures that this method will be called exactly once during
  /// the lifetime of the [Game] instance. Do not call this method manually.
  Future<void>? onLoad() => null;

  void onMount() {}

  /// Marks game as attached to any Flutter widget tree.
  ///
  /// Should not be called manually.
  void attach(PipelineOwner owner, GameRenderBox gameRenderBox) {
    if (isAttached) {
      throw UnsupportedError(
        '''
      Game attachment error:
      A game instance can only be attached to one widget at a time.
      ''',
      );
    }
    _gameRenderBox = gameRenderBox;
    overlays._game = this;

    onAttach();
  }

  /// Called when the game has been attached. This can be overridden
  /// to add logic that requires the game to already be attached
  /// to the widget tree.
  void onAttach() {}

  /// Marks game as no longer attached to any Flutter widget tree.
  ///
  /// Should not be called manually.
  void detach() {
    _gameRenderBox = null;

    onDetach();
  }

  /// Called when the game is about to be removed from the Flutter widget tree,
  /// but before it is actually removed.
  void onRemove() {}

  /// Called after the game has left the widget tree.
  /// This can be overridden to add logic that requires the game
  /// not be on the flutter widget tree anymore.
  void onDetach() {}

  /// Converts a global coordinate (i.e. w.r.t. the app itself) to a local
  /// coordinate (i.e. w.r.t. he game widget).
  /// If the widget occupies the whole app ("full screen" games), or is not
  /// attached to Flutter, this operation is the identity.
  Vector2 convertGlobalToLocalCoordinate(Vector2 point) {
    if (!isAttached) {
      return point.clone();
    }
    return _gameRenderBox!.globalToLocal(point.toOffset()).toVector2();
  }

  /// Converts a local coordinate (i.e. w.r.t. the game widget) to a global
  /// coordinate (i.e. w.r.t. the app itself).
  /// If the widget occupies the whole app ("full screen" games), or is not
  /// attached to Flutter, this operation is the identity.
  Vector2 convertLocalToGlobalCoordinate(Vector2 point) {
    if (!isAttached) {
      return point.clone();
    }
    return _gameRenderBox!.localToGlobal(point.toOffset()).toVector2();
  }

  /// This is the projector used by all components that respect the camera
  /// (`respectCamera = true`).
  /// This can be overridden on your [Game] implementation.
  Projector projector = IdentityProjector();

  /// This is the projector used by components that don't respect the camera
  /// (`positionType = PositionType.viewport;`).
  /// This can be overridden on your [Game] implementation.
  Projector viewportProjector = IdentityProjector();

  /// Utility method to load and cache the image for a sprite based on its
  /// options.
  Future<Sprite> loadSprite(
    String path, {
    Vector2? srcSize,
    Vector2? srcPosition,
  }) {
    return Sprite.load(
      path,
      srcPosition: srcPosition,
      srcSize: srcSize,
      images: images,
    );
  }

  /// Utility method to load and cache the image for a sprite animation based on
  /// its options.
  Future<SpriteAnimation> loadSpriteAnimation(
    String path,
    SpriteAnimationData data,
  ) {
    return SpriteAnimation.load(
      path,
      data,
      images: images,
    );
  }

  bool _paused = false;

  /// Returns is the engine if currently paused or running
  bool get paused => _paused;

  /// Pauses or resume the engine
  set paused(bool value) {
    if (pauseEngineFn != null && resumeEngineFn != null) {
      if (value) {
        pauseEngine();
      } else {
        resumeEngine();
      }
    } else {
      _paused = value;
    }
  }

  /// Pauses the engine game loop execution.
  void pauseEngine() {
    _paused = true;
    pauseEngineFn?.call();
  }

  /// Resumes the engine game loop execution.
  void resumeEngine() {
    _paused = false;
    resumeEngineFn?.call();
  }

  VoidCallback? pauseEngineFn;
  VoidCallback? resumeEngineFn;

  /// A property that stores an [_ActiveOverlays]
  ///
  /// This is useful to render widgets on top of a game, such as a pause menu.
  /// Overlays can be made visible via [overlays].add or hidden via
  /// [overlays].remove.
  ///
  /// For example:
  /// ```
  /// final pauseOverlayIdentifier = 'PauseMenu';
  /// overlays.add(pauseOverlayIdentifier); // marks 'PauseMenu' to be rendered.
  /// overlays.remove(pauseOverlayIdentifier); // hides 'PauseMenu'.
  /// ```
  final overlays = _ActiveOverlays();

  /// Used to change the mouse cursor of the GameWidget running this game.
  /// Setting the value to null will make the GameWidget defer the choice
  /// of the cursor to the closest region available on the tree.
  MouseCursor get mouseCursor => _mouseCursor;
  MouseCursor _mouseCursor = MouseCursor.defer;

  set mouseCursor(MouseCursor value) {
    _mouseCursor = value;
    _refreshWidget();
  }

  @visibleForTesting
  final List<VoidCallback> gameStateListeners = [];

  void addGameStateListener(VoidCallback callback) {
    gameStateListeners.add(callback);
  }

  void removeGameStateListener(VoidCallback callback) {
    gameStateListeners.remove(callback);
  }

  /// When a Game is attached to a `GameWidget`, this method will force that
  /// widget to be rebuilt. This can be used when updating any property which is
  /// implemented within the Flutter tree.
  void _refreshWidget() {
    gameStateListeners.forEach((callback) => callback());
  }
}

/// A helper class used to control the visibility of overlays on a [Game]
/// instance. See [Game.overlays].
class _ActiveOverlays {
  Game? _game;
  final Set<String> _activeOverlays = {};

  /// Clear all active overlays.
  void clear() {
    _activeOverlays.clear();
    _game?._refreshWidget();
  }

  /// Marks the [overlayName] to be rendered.
  bool add(String overlayName) {
    final setChanged = _activeOverlays.add(overlayName);
    if (setChanged) {
      _game?._refreshWidget();
    }
    return setChanged;
  }

  /// Marks [overlayNames] to be rendered.
  void addAll(Iterable<String> overlayNames) {
    final overlayCountBeforeAdded = _activeOverlays.length;
    _activeOverlays.addAll(overlayNames);

    final overlayCountAfterAdded = _activeOverlays.length;
    if (overlayCountBeforeAdded != overlayCountAfterAdded) {
      _game?._refreshWidget();
    }
  }

  /// Hides the [overlayName].
  bool remove(String overlayName) {
    final hasRemoved = _activeOverlays.remove(overlayName);
    if (hasRemoved) {
      _game?._refreshWidget();
    }
    return hasRemoved;
  }

  /// Hides multiple overlays specified in [overlayNames].
  void removeAll(Iterable<String> overlayNames) {
    final overlayCountBeforeRemoved = _activeOverlays.length;
    _activeOverlays.removeAll(overlayNames);

    final overlayCountAfterRemoved = _activeOverlays.length;
    if (overlayCountBeforeRemoved != overlayCountAfterRemoved) {
      _game?._refreshWidget();
    }
  }

  /// The names of all currently active overlays.
  Set<String> get value => _activeOverlays;

  /// Returns if the given [overlayName] is active
  bool isActive(String overlayName) => _activeOverlays.contains(overlayName);
}
