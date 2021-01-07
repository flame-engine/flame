import 'dart:async';
import 'dart:ui';

import 'package:flame/sprite_batch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../assets/assets_cache.dart';
import '../assets/images.dart';
import '../extensions/vector2.dart';
import '../keyboard.dart';
import '../sprite.dart';
import '../sprite_animation.dart';

/// Represents a generic game.
///
/// Subclass this to implement the [update] and [render] methods.
/// Flame will deal with calling these methods properly when the game's widget is rendered.
abstract class Game {
  final images = Images();
  final assets = AssetsCache();
  BuildContext buildContext;

  /// Current game viewport size, updated every resize via the [resize] method hook
  final Vector2 size = Vector2.zero();

  bool get isAttached => buildContext != null;

  /// Returns the game background color.
  /// By default it will return a black color.
  /// It cannot be changed at runtime, because the game widget does not get rebuild when this value changes.
  Color backgroundColor() => const Color(0xFF000000);

  /// Implement this method to update the game state, given that a time [t] has passed.
  ///
  /// Keep the updates as short as possible. [t] is in seconds, with microseconds precision.
  void update(double t);

  /// Implement this method to render the current game state in the [canvas].
  void render(Canvas canvas);

  /// This is the resize hook; every time the game widget is resized, this hook is called.
  ///
  /// The default implementation just sets the new size on the size field
  @mustCallSuper
  void onResize(Vector2 size) {
    this.size.setFrom(size);
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
  void attach(PipelineOwner owner, BuildContext context) {
    if (isAttached) {
      throw UnsupportedError("""
      Game attachment error:
      A game instance can only be attached to one widget at a time.
      """);
    }
    buildContext = context;
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
    buildContext = null;
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

  /// Utility method to load and cache the image for a sprite based on its options
  Future<Sprite> loadSprite(
    String path, {
    Vector2 srcSize,
    Vector2 srcPosition,
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

  /// Utility method to load and cache the image for a [SpriteBatch] based on its options
  Future<SpriteBatch> loadSpriteBatch(
    String path, {
    Color defaultColor = const Color(0x00000000),
    BlendMode defaultBlendMode = BlendMode.srcOver,
    RSTransform defaultTransform,
  }) {
    return SpriteBatch.load(
      path,
      defaultColor: defaultColor,
      defaultBlendMode: defaultBlendMode,
      defaultTransform: defaultTransform,
      images: images,
    );
  }

  /// Flag to tell the game loop if it should start running upon creation
  bool runOnCreation = true;

  /// Pauses the engine game loop execution
  void pauseEngine() => pauseEngineFn?.call();

  /// Resumes the engine game loop execution
  void resumeEngine() => resumeEngineFn?.call();

  VoidCallback pauseEngineFn;
  VoidCallback resumeEngineFn;

  /// Use this method to load the assets need for the game instance to run
  Future<void> onLoad() async {}

  /// A property that stores an [ActiveOverlaysNotifier]
  ///
  /// This is useful to render widgets above a game, like a pause menu for example.
  /// Overlays visible or hidden via [overlays.add] or [overlays.remove], respectively.
  ///
  /// Ex:
  /// ```
  /// final pauseOverlayIdentifier = "PauseMenu";
  /// overlays.add(pauseOverlayIdentifier); // marks "PauseMenu" to be rendered.
  /// overlays.remove(pauseOverlayIdentifier); // marks "PauseMenu" to not be rendered.
  /// ```
  ///
  /// See also:
  /// - [new GameWidget]
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
  /// - [new GameWidget]
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
  /// - [new GameWidget]
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
