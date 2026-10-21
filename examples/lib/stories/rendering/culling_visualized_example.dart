import 'dart:math';
import 'dart:ui';

import 'package:examples/stories/rendering/culling_example.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;

class CullingVisualizedExample({
  final bool culled = true,
  final int amount = 10000,
}) extends FlameGame with KeyboardEvents {
  static const description = '''
See which sprites `CullWhenOffscreen` skips. The big view shows the whole field.
The small view in the bottom right corner is a second camera that moves around,
and it is the one that does the culling. The white box shows what it sees.

A sprite is bright in the big view if the small camera drew it, and dim if the
small camera skipped it.

Press C, or use the "Culled" knob, to turn culling on and off. With culling on,
only the sprites near the white box are bright. With culling off, the small
camera draws every sprite, so all of them are bright.

The FPS at the top is for the whole game. While the big view is on, it sets the
FPS, because it always draws every sprite. Press V to hide the big view. Then
the FPS is the FPS of the small camera alone.

The "draw time" line is how long the small camera needs to draw its sprites in
Dart. It does not include the work of the GPU.
  ''';

  static const _fieldSize = 4000.0;
  static final Vector2 _innerViewSize = Vector2(320, 240);
  static const _margin = 20.0;

  late final _TimedCamera _innerCamera;

  /// The small camera that moves around and that does the culling.
  CameraComponent get innerCamera => _innerCamera;

  /// Counts the frames, so that sprites know when they were last drawn by the
  /// inner camera.
  int frame = 0;

  /// How many sprites the inner camera drew in this frame, and in the last.
  int innerRenderCount = 0;
  int _lastInnerRenderCount = 0;

  late bool _culled = culled;
  late final CullingStatusText _statusText;
  late final World _emptyWorld;
  bool _bigViewVisible = true;
  late final TextComponent _countText;
  late final TextComponent _timeText;
  double _time = 0;

  @override
  Future<void> onLoad() async {
    final animations = await loadCullingAnimations(this);
    final random = Random(1);
    world.addAll([
      for (var i = 0; i < amount; i++)
        _Sprite(
          animation: animations[random.nextInt(animations.length)],
          position: Vector2(
            (random.nextDouble() - 0.5) * _fieldSize,
            (random.nextDouble() - 0.5) * _fieldSize,
          ),
        )..cullingEnabled = _culled,
      _InnerViewOutline(),
    ]);

    // The big camera looks at this empty world when the big view is hidden.
    _emptyWorld = World();
    add(_emptyWorld);

    // The default camera is the big one, and it shows the whole field.
    camera.viewfinder.visibleGameSize = Vector2.all(_fieldSize * 1.05);

    // The inner camera is added after the default camera, so it is drawn on
    // top of it.
    _innerCamera = _TimedCamera(
      world: world,
      viewport: FixedSizeViewport(_innerViewSize.x, _innerViewSize.y)
        ..anchor = Anchor.bottomRight,
    );
    _innerCamera.viewport.add(
      RectangleComponent(
        size: _innerViewSize,
        paint: BasicPalette.white.paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      ),
    );
    add(_innerCamera);

    camera.viewport.add(
      PositionComponent(
        position: Vector2.all(10),
        size: Vector2(480, 196),
        children: [
          RectangleComponent(
            size: Vector2(480, 196),
            paint: BasicPalette.black.withAlpha(140).paint(),
          ),
          FpsTextComponent(
            position: Vector2(10, 8),
            textRenderer: cullingHudText,
          ),
          _statusText = CullingStatusText(
            culled: _culled,
            position: Vector2(10, 36),
          ),
          _countText = TextComponent(
            position: Vector2(10, 70),
            textRenderer: cullingHudText,
          ),
          _timeText = TextComponent(
            position: Vector2(10, 98),
            textRenderer: cullingHudText,
          ),
          TextComponent(
            text: 'Bright: drawn by the small camera',
            position: Vector2(10, 134),
            textRenderer: cullingHudText,
          ),
          TextComponent(
            text: 'C: culling on/off     V: big view on/off',
            position: Vector2(10, 162),
            textRenderer: cullingHudText,
          ),
        ],
      ),
    );
    _placeInnerCamera(size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _placeInnerCamera(size);
    }
  }

  void _placeInnerCamera(Vector2 size) {
    innerCamera.viewport.position = size - Vector2.all(_margin);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyC) {
      _culled = !_culled;
      _statusText.culled = _culled;
      for (final sprite in world.children.query<_Sprite>()) {
        sprite.cullingEnabled = _culled;
      }
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyV) {
      _bigViewVisible = !_bigViewVisible;
      camera.world = _bigViewVisible ? world : _emptyWorld;
      return KeyEventResult.handled;
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    innerCamera.viewfinder.position = Vector2(
      cos(_time * 0.3) * _fieldSize * 0.35,
      sin(_time * 0.2) * _fieldSize * 0.35,
    );
    _countText.text =
        'Small camera drew: $_lastInnerRenderCount/$amount sprites';
    final milliseconds = _innerCamera.drawMilliseconds;
    if (milliseconds > 0) {
      _timeText.text =
          'Small camera draw time: ${milliseconds.toStringAsFixed(1)} ms';
    }
  }

  @override
  void render(Canvas canvas) {
    frame++;
    _lastInnerRenderCount = innerRenderCount;
    innerRenderCount = 0;
    super.render(canvas);
  }
}

class _Sprite({
  required SpriteAnimation super.animation,
  super.position,
}) extends SpriteAnimationComponent
    with CullWhenOffscreen, HasGameRef<CullingVisualizedExample> {
  this : super(size: Vector2.all(48), anchor: Anchor.center);

  static const _dimmedOpacity = 0.2;

  int _lastInnerFrame = -10;
  double _currentOpacity = 1;

  @override
  void render(Canvas canvas) {
    final game = gameRef;
    final isInner = CameraComponent.currentCameras.last == game.innerCamera;
    if (isInner) {
      _lastInnerFrame = game.frame;
      game.innerRenderCount++;
    }
    // The big camera draws first, so it looks at what the small camera drew in
    // the frame before.
    final wasDrawnByInner = isInner || game.frame - _lastInnerFrame <= 1;
    final opacity = wasDrawnByInner ? 1.0 : _dimmedOpacity;
    if (opacity != _currentOpacity) {
      _currentOpacity = opacity;
      this.opacity = opacity;
    }
    super.render(canvas);
  }
}

/// Draws a box around the area that the inner camera sees. It is only drawn by
/// the big camera.
class _InnerViewOutline()
    extends Component
    with HasGameRef<CullingVisualizedExample> {
  final Paint _paint = BasicPalette.white.paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 12;

  this : super(priority: 1000);

  @override
  void render(Canvas canvas) {
    final game = gameRef;
    if (CameraComponent.currentCameras.last == game.innerCamera) {
      return;
    }
    canvas.drawRect(game.innerCamera.visibleWorldRect, _paint);
  }
}

/// A camera that measures how long it takes to draw its world.
class _TimedCamera({
  super.world,
  super.viewport,
}) extends CameraComponent {
  final Stopwatch _stopwatch = Stopwatch();

  /// The average time the camera takes to draw, in milliseconds.
  double drawMilliseconds = 0;

  @override
  void renderTree(Canvas canvas) {
    _stopwatch
      ..reset()
      ..start();
    super.renderTree(canvas);
    _stopwatch.stop();
    final milliseconds = _stopwatch.elapsedMicroseconds / 1000;
    drawMilliseconds = drawMilliseconds == 0
        ? milliseconds
        : drawMilliseconds * 0.95 + milliseconds * 0.05;
  }
}
