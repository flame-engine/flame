import 'dart:async';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../assets/assets_cache.dart';
import '../assets/images.dart';
import '../extensions/offset.dart';
import '../extensions/vector2.dart';
import '../keyboard.dart';
import '../sprite.dart';
import '../sprite_animation.dart';
import 'game_render_box.dart';
import 'projector.dart';

/// Represents a generic game.
///
/// Subclass this to implement the [update] and [render] methods.
/// Flame will deal with calling these methods properly when the game's widget is rendered.
abstract class Game extends Projector {
  final images = Images();
  final assets = AssetsCache();

  /// Just a reference back to the render box that is kept up to date by the engine.
  GameRenderBox? _gameRenderBox;

  /// Currently attached build context. Can be null if not attached.
  BuildContext? get buildContext => _gameRenderBox?.buildContext;

  /// Whether the game widget was attached to the Flutter tree.
  bool get isAttached => buildContext != null;

  /// Current size of the game as provided by the framework; it will be null if layout has not been computed yet.
  ///
  /// Use [size] and [hasLayout] for safe access.
  Vector2? _size;

  /// Current game viewport size, updated every resize via the [onResize] method hook
  Vector2 get size {
    assertHasLayout();
    return _size!;
  }

  /// Indicates if the this game instance had its layout layed into the GameWidget
  /// Only this is true, the game is ready to have its size used or in the case
  /// of a BaseGame, to receive components.
  bool get hasLayout => _size != null;

  /// Returns the game background color.
  /// By default it will return a black color.
  /// It cannot be changed at runtime, because the game widget does not get rebuild when this value changes.
  Color backgroundColor() => const Color(0xFF000000);

  /// Implement this method to update the game state, given the time [dt] that has passed since the last update.
  ///
  /// Keep the updates as short as possible. [dt] is in seconds, with microseconds precision.
  void update(double dt);

  /// Implement this method to render the current game state in the [canvas].
  void render(Canvas canvas);

  /// This is the resize hook; every time the game widget is resized, this hook is called.
  ///
  /// The default implementation just sets the new size on the size field
  @mustCallSuper
  void onResize(Vector2 size) {
    _size = (_size ?? Vector2.zero())..setFrom(size);
  }

  @protected
  void assertHasLayout() {
    assert(
      hasLayout,
      '"size" is not ready yet. Did you try to access it on the Game constructor? Use the "onLoad" method instead.',
    );
  }

  /// This is the lifecycle state change hook; every time the game is resumed, paused or suspended, this is called.
  ///
  /// The default implementation does nothing; override to use the hook.
  /// Check [AppLifecycleState] for details about the events received.
  void lifecycleStateChange(AppLifecycleState state) {}

  /// Use for calculating the FPS.
  void onTimingsCallback(List<FrameTiming> timings) {}

  void _handleKeyEvent(RawKeyEvent e) {
    (this as KeyboardEvents).onKeyEvent(e);
  }

  /// Marks game as not attached tto any widget tree.
  ///
  /// Should be called manually.
  void attach(PipelineOwner owner, GameRenderBox gameRenderBox) {
    if (isAttached) {
      throw UnsupportedError('''
      Game attachment error:
      A game instance can only be attached to one widget at a time.
      ''');
    }
    _gameRenderBox = gameRenderBox;
    onAttach();
  }

  // Called when the Game widget is attached
  @mustCallSuper
  void onAttach() {
    if (this is KeyboardEvents) {
      RawKeyboard.instance.addListener(_handleKeyEvent);
    }
  }

  /// Marks game as not attached tto any widget tree.
  ///
  /// Should not be called manually.
  void detach() {
    _gameRenderBox = null;
    _size = null;
    onDetach();
  }

  // Called when the Game widget is detached
  @mustCallSuper
  void onDetach() {
    // Keeping this here, because if we leave this on HasWidgetsOverlay
    // and somebody overrides this and forgets to call the stream close
    // we can face some leaks.
    if (this is KeyboardEvents) {
      RawKeyboard.instance.removeListener(_handleKeyEvent);
    }
    images.clearCache();
  }

  /// Converts a global coordinate (i.e. w.r.t. the app itself) to a local
  /// coordinate (i.e. w.r.t. he game widget).
  /// If the widget occupies the whole app ("full screen" games), this operation
  /// is the identity.
  Vector2 convertGlobalToLocalCoordinate(Vector2 point) {
    if (!isAttached) {
      throw UnsupportedError(
        'This method can only be called if the game is attached',
      );
    }
    return _gameRenderBox!.globalToLocal(point.toOffset()).toVector2();
  }

  /// Converts a local coordinate (i.e. w.r.t. the game widget) to a global
  /// coordinate (i.e. w.r.t. the app itself).
  /// If the widget occupies the whole app ("full screen" games), this operation
  /// is the identity.
  Vector2 convertLocalToGlobalCoordinate(Vector2 point) {
    if (!isAttached) {
      throw UnsupportedError(
        'This method can only be called if the game is attached',
      );
    }
    return _gameRenderBox!.localToGlobal(point.toOffset()).toVector2();
  }

  @override
  Vector2 unprojectVector(Vector2 vector) => vector;

  @override
  Vector2 projectVector(Vector2 vector) => vector;

  @override
  Vector2 unscaleVector(Vector2 vector) => vector;

  @override
  Vector2 scaleVector(Vector2 vector) => vector;

  /// Utility method to load and cache the image for a sprite based on its options
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

  /// Utility method to load and cache the image for a sprite animation based on its options
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

  /// Flag to tell the game loop if it should start running upon creation
  bool runOnCreation = true;

  /// Pauses the engine game loop execution
  void pauseEngine() => pauseEngineFn?.call();

  /// Resumes the engine game loop execution
  void resumeEngine() => resumeEngineFn?.call();

  VoidCallback? pauseEngineFn;
  VoidCallback? resumeEngineFn;

  /// Use this method to load the assets need for the game instance to run
  Future<void> onLoad() async {}

  /// A property that stores an [ActiveOverlaysNotifier]
  ///
  /// This is useful to render widgets above a game, like a pause menu for example.
  /// Overlays visible or hidden via [overlays].add or [overlays].remove, respectively.
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
}

/// A [ChangeNotifier] used to control the visibility of overlays on a [Game] instance.
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
