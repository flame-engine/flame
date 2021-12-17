import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../../components.dart';
import '../../assets/assets_cache.dart';
import '../../assets/images.dart';
import '../../extensions/offset.dart';
import '../game_render_box.dart';
import '../projector.dart';
import 'loadable.dart';

/// This gives access to a low-level game API, to not build everything from a
/// low level `FlameGame` should be used.
///
/// Add this mixin to your game class and implement the [update] and [render]
/// methods to use it in a `GameWidget`.
/// Flame will deal with calling these methods properly when the game's widget
/// is rendered.
mixin Game on Loadable {
  final images = Images();
  final assets = AssetsCache();

  /// This should update the state of the game.
  void update(double dt);

  /// This should render the game.
  void render(Canvas canvas);

  /// Just a reference back to the render box that is kept up to date by the
  /// engine.
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

  /// Current game viewport size, updated every resize via the [onGameResize]
  /// method hook.
  Vector2 get size {
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
  @override
  @mustCallSuper
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
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

  /// Use for calculating the FPS.
  void onTimingsCallback(List<FrameTiming> timings) {}

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

  /// A property that stores an [ActiveOverlaysNotifier]
  ///
  /// This is useful to render widgets above a game, like a pause menu for
  /// example.
  /// Overlays visible or hidden via [overlays].add or [overlays].remove,
  /// respectively.
  ///
  /// Ex:
  /// ```
  /// final pauseOverlayIdentifier = 'PauseMenu';
  /// overlays.add(pauseOverlayIdentifier); // marks 'PauseMenu' to be rendered.
  /// overlays.remove(pauseOverlayIdentifier); // marks 'PauseMenu' to not be rendered.
  /// ```
  ///
  /// See also:
  /// - GameWidget
  /// - [Game.overlays]
  final overlays = ActiveOverlaysNotifier();

  /// Used to change the mouse cursor of the GameWidget running this game.
  /// Setting the value to null will make the GameWidget defer the choice
  /// of the cursor to the closest region available on the tree.
  final mouseCursor = ValueNotifier<MouseCursor?>(null);
}

/// A [ChangeNotifier] used to control the visibility of overlays on a [Game]
/// instance.
///
/// To learn more, see:
/// - [Game.overlays]
class ActiveOverlaysNotifier extends ChangeNotifier {
  final Set<String> _activeOverlays = {};

  /// Mark a, overlay to be rendered.
  ///
  /// See also:
  /// - GameWidget
  /// - [Game.overlays]
  bool add(String overlayName) {
    final setChanged = _activeOverlays.add(overlayName);
    if (setChanged) {
      notifyListeners();
    }
    return setChanged;
  }

  /// Mark a, overlay to not be rendered.
  ///
  /// See also:
  /// - GameWidget
  /// - [Game.overlays]
  bool remove(String overlayName) {
    final hasRemoved = _activeOverlays.remove(overlayName);
    if (hasRemoved) {
      notifyListeners();
    }
    return hasRemoved;
  }

  /// A [Set] of the active overlay names.
  Set<String> get value => _activeOverlays;

  /// Returns if the given [overlayName] is active
  bool isActive(String overlayName) => _activeOverlays.contains(overlayName);
}
