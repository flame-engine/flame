import 'dart:math';
import 'dart:ui';

import 'package:examples/stories/tiled/tiled_culling_example.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;

class TiledCullingVisualizedExample({
  final bool culled = true,
}) extends FlameGame with KeyboardEvents {
  static const description = '''
See which parts of a Tiled map are skipped when culling is on. The big view
shows the whole map. The small view in the bottom right corner is a second
camera that moves around, and it is the one that does the culling. The white box
shows what it sees.

The map is split into chunks of 16 x 16 tiles, which are the squares of the
grid. A chunk is green if the small camera draws it. The small camera skips the
chunks that are not green, since they are out of its view.

Press C, or use the "Culled" knob, to turn culling on and off. With culling off,
the small camera draws every chunk, so they are all green.

The FPS at the top is for the whole game. While the big view is on, it sets the
FPS, because it always draws the whole map. Press V to hide the big view. Then
the FPS is the FPS of the small camera alone.

The "draw time" line is how long the small camera needs to draw the map in Dart.
It does not include the work of the GPU.
  ''';

  static final Vector2 _innerViewSize = Vector2(320, 240);
  static const _margin = 20.0;

  late final _TimedCamera _innerCamera;

  /// The small camera that moves around and that does the culling.
  CameraComponent get innerCamera => _innerCamera;

  late bool _culled = culled;
  late final TimedTiledComponent _culledMap;
  late final TimedTiledComponent _plainMap;
  late final CullingStatusText _statusText;
  late final World _emptyWorld;
  bool _bigViewVisible = true;
  late final _ChunkGrid _grid;
  late final TextComponent _chunksText;
  late final TextComponent _timeText;
  double _time = 0;

  /// Whether the small camera skips the chunks that are out of its view.
  bool get isCulled => _culled;

  TimedTiledComponent get _currentMap => _culled ? _culledMap : _plainMap;

  @override
  Future<void> onLoad() async {
    // The same map twice, so that the key can switch between them instantly.
    _culledMap = await loadTiledCullingMap(culled: true);
    _plainMap = await loadTiledCullingMap(culled: false);
    world.addAll([_currentMap, _grid = _ChunkGrid()]);

    // The big camera looks at this empty world when the big view is hidden.
    _emptyWorld = World();
    add(_emptyWorld);

    // The default camera is the big one, and it shows the whole map.
    camera.viewfinder
      ..visibleGameSize = Vector2.all(tiledCullingMapSize * 1.02)
      ..position = Vector2.all(tiledCullingMapSize / 2);

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
        size: Vector2(460, 196),
        children: [
          RectangleComponent(
            size: Vector2(460, 196),
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
          _chunksText = TextComponent(
            position: Vector2(10, 70),
            textRenderer: cullingHudText,
          ),
          _timeText = TextComponent(
            position: Vector2(10, 98),
            textRenderer: cullingHudText,
          ),
          TextComponent(
            text: 'Green: chunks drawn by the small camera',
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
      world.remove(_currentMap);
      _culled = !_culled;
      world.add(_currentMap);
      _statusText.culled = _culled;
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
    const center = tiledCullingMapSize / 2;
    innerCamera.viewfinder.position = Vector2(
      center + cos(_time * 0.3) * tiledCullingMapSize * 0.35,
      center + sin(_time * 0.2) * tiledCullingMapSize * 0.35,
    );
    _chunksText.text =
        'Small camera draws: ${_grid.chunksInView}/${_grid.chunkCount} chunks';
    final milliseconds = _innerCamera.drawMilliseconds;
    if (milliseconds > 0) {
      _timeText.text =
          'Small camera draw time: ${milliseconds.toStringAsFixed(1)} ms';
    }
  }
}

/// Draws the chunks of the map, and fills the ones that the small camera
/// draws. It is only drawn by the big camera.
class _ChunkGrid()
    extends Component
    with HasGameRef<TiledCullingVisualizedExample> {
  static const _chunkSize = tiledCullingChunkSize * tiledCullingTileSize;
  static const _chunksPerSide = tiledCullingTiles ~/ tiledCullingChunkSize;

  final Paint _linePaint = BasicPalette.white.withAlpha(70).paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  final Paint _fillPaint = Paint()..color = const Color(0x664DFF6A);
  final Paint _viewPaint = BasicPalette.white.paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 12;

  this : super(priority: 1000);

  int get chunkCount => _chunksPerSide * _chunksPerSide;

  /// How many chunks the small camera draws.
  int chunksInView = 0;

  Rect _chunk(int x, int y) =>
      Rect.fromLTWH(x * _chunkSize, y * _chunkSize, _chunkSize, _chunkSize);

  bool _isDrawn(Rect chunk, Rect view) =>
      !gameRef.isCulled || chunk.overlaps(view);

  @override
  void update(double dt) {
    final view = gameRef.innerCamera.visibleWorldRect;
    var inView = 0;
    for (var y = 0; y < _chunksPerSide; y++) {
      for (var x = 0; x < _chunksPerSide; x++) {
        if (_isDrawn(_chunk(x, y), view)) {
          inView++;
        }
      }
    }
    chunksInView = inView;
  }

  @override
  void render(Canvas canvas) {
    final game = gameRef;
    if (CameraComponent.currentCameras.last == game.innerCamera) {
      return;
    }
    final view = game.innerCamera.visibleWorldRect;
    for (var y = 0; y < _chunksPerSide; y++) {
      for (var x = 0; x < _chunksPerSide; x++) {
        final chunk = _chunk(x, y);
        if (_isDrawn(chunk, view)) {
          canvas.drawRect(chunk, _fillPaint);
        }
        canvas.drawRect(chunk, _linePaint);
      }
    }
    canvas.drawRect(view, _viewPaint);
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
