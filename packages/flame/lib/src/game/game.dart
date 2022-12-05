import 'dart:typed_data';

import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/flame.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flame/src/game/overlay_manager.dart';
import 'package:flame/src/game/projector.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'package:meta/meta.dart';

/// This gives access to a low-level game API, to not build everything from a
/// low level `FlameGame` should be used.
///
/// You can either extend this class, or add it as a mixin.
///
/// Methods [update] and [render] need to be implemented in order to connect
/// your class with the internal game loop.
abstract class Game {
  /// The cache of all images loaded into the game. This defaults to the global
  /// [Flame.images] cache, but you can replace it with a new cache instance if
  /// needed.
  Images images = Flame.images;

  /// The cache of all (non-image) assets loaded into the game. This defaults to
  /// the global [Flame.assets] cache, but you can replace this with another
  /// instance if needed.
  AssetsCache assets = Flame.assets;

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
    _paused = value;

    final gameLoop = _gameRenderBox?.gameLoop;
    if (gameLoop != null) {
      if (value) {
        gameLoop.stop();
      } else {
        gameLoop.start();
      }
    }
  }

  /// Pauses the engine game loop execution.
  void pauseEngine() {
    _paused = true;
    _gameRenderBox?.gameLoop?.stop();
  }

  /// Resumes the engine game loop execution.
  void resumeEngine() {
    _paused = false;
    _gameRenderBox?.gameLoop?.start();
  }

  /// A property that stores an [OverlayManager]
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
  late final overlays = OverlayManager(this);

  /// Used to change the mouse cursor of the GameWidget running this game.
  /// Setting the value to null will make the GameWidget defer the choice
  /// of the cursor to the closest region available on the tree.
  MouseCursor get mouseCursor => _mouseCursor;
  MouseCursor _mouseCursor = MouseCursor.defer;

  set mouseCursor(MouseCursor value) {
    _mouseCursor = value;
    refreshWidget();
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
  @internal
  void refreshWidget() {
    gameStateListeners.forEach((callback) => callback());
  }
}

class RenderContext {
  final Canvas canvas;
  final String? secondaryKey;

  RenderContext(
    this.canvas, [
    this.secondaryKey,
  ]);
}

class CanvasSecondary implements Canvas {
  CanvasSecondary(this.canvas, this.secondaryKey);

  final Canvas canvas;

  final String secondaryKey;

  @override
  void clipPath(Path path, {bool doAntiAlias = true}) {
    canvas.clipPath(path, doAntiAlias: doAntiAlias);
  }

  @override
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) {
    canvas.clipRRect(rrect, doAntiAlias: doAntiAlias);
  }

  @override
  void clipRect(
    Rect rect, {
    ClipOp clipOp = ClipOp.intersect,
    bool doAntiAlias = true,
  }) {
    canvas.clipRect(rect, clipOp: clipOp, doAntiAlias: doAntiAlias);
  }

  @override
  void drawArc(
    Rect rect,
    double startAngle,
    double sweepAngle,
    bool useCenter,
    Paint paint,
  ) {
    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  void drawAtlas(
    Image atlas,
    List<RSTransform> transforms,
    List<Rect> rects,
    List<Color>? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  ) {
    canvas.drawAtlas(
      atlas,
      transforms,
      rects,
      colors,
      blendMode,
      cullRect,
      paint,
    );
  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    canvas.drawCircle(c, radius, paint);
  }

  @override
  void drawColor(Color color, BlendMode blendMode) {
    canvas.drawColor(color, blendMode);
  }

  @override
  void drawDRRect(RRect outer, RRect inner, Paint paint) {
    canvas.drawDRRect(outer, inner, paint);
  }

  @override
  void drawImage(Image image, Offset offset, Paint paint) {
    canvas.drawImage(image, offset, paint);
  }

  @override
  void drawImageNine(Image image, Rect center, Rect dst, Paint paint) {
    canvas.drawImageNine(image, center, dst, paint);
  }

  @override
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) {
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    canvas.drawLine(p1, p2, paint);
  }

  @override
  void drawOval(Rect rect, Paint paint) {
    canvas.drawOval(rect, paint);
  }

  @override
  void drawPaint(Paint paint) {
    canvas.drawPaint(paint);
  }

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) {
    canvas.drawParagraph(paragraph, offset);
  }

  @override
  void drawPath(Path path, Paint paint) {
    canvas.drawPath(path, paint);
  }

  @override
  void drawPicture(Picture picture) {
    canvas.drawPicture(picture);
  }

  @override
  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint) {
    canvas.drawPoints(pointMode, points, paint);
  }

  @override
  void drawRRect(RRect rrect, Paint paint) {
    canvas.drawRRect(rrect, paint);
  }

  @override
  void drawRawAtlas(
    Image atlas,
    Float32List rstTransforms,
    Float32List rects,
    Int32List? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  ) {
    canvas.drawRawAtlas(
      atlas,
      rstTransforms,
      rects,
      colors,
      blendMode,
      cullRect,
      paint,
    );
  }

  @override
  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) {
    canvas.drawRawPoints(pointMode, points, paint);
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    canvas.drawRect(rect, paint);
  }

  @override
  void drawShadow(
    Path path,
    Color color,
    double elevation,
    bool transparentOccluder,
  ) {
    canvas.drawShadow(path, color, elevation, transparentOccluder);
  }

  @override
  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) {
    canvas.drawVertices(vertices, blendMode, paint);
  }

  @override
  Rect getDestinationClipBounds() {
    return canvas.getDestinationClipBounds();
  }

  @override
  Rect getLocalClipBounds() {
    return canvas.getLocalClipBounds();
  }

  @override
  int getSaveCount() {
    return canvas.getSaveCount();
  }

  @override
  Float64List getTransform() {
    return canvas.getTransform();
  }

  @override
  void restore() {
    canvas.restore();
  }

  @override
  void restoreToCount(int count) {
    canvas.restoreToCount(count);
  }

  @override
  void rotate(double radians) {
    canvas.rotate(radians);
  }

  @override
  void save() {
    canvas.save();
  }

  @override
  void saveLayer(Rect? bounds, Paint paint) {
    canvas.saveLayer(bounds, paint);
  }

  @override
  void scale(double sx, [double? sy]) {
    canvas.scale(sx, sy);
  }

  @override
  void skew(double sx, double sy) {
    canvas.skew(sx, sy);
  }

  @override
  void transform(Float64List matrix4) {
    canvas.transform(matrix4);
  }

  @override
  void translate(double dx, double dy) {
    canvas.translate(dx, dy);
  }
}
