import 'dart:math';
import 'dart:ui';

import 'package:examples/commons/culling_story.dart';
import 'package:examples/stories/tiled/tiled_culling_example.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;

class TiledCullingVisualizedExample({
  bool culled = true,
  final TiledCullingOrientation orientation =
      TiledCullingOrientation.orthogonal,
  final int chunkSize = tiledCullingChunkSize,
  @override var double cameraSpeed = 1,
  bool bigView = true,
}) extends FlameGame with KeyboardEvents, CullingControls {
  static const description = '''
See which parts of a Tiled map are skipped when culling is on. The big view
shows the whole map. The small view in the bottom right corner is a second
camera that moves around, and it is the one that does the culling. The white box
shows what it sees.

The map is split into chunks of 16 x 16 tiles (the "Chunk size" knob changes
it), which are the shapes of the grid. A chunk is green if the small camera
draws it. The small camera skips the chunks that are not green, since they are
out of its view. Flame compares the view with the smallest box around each
chunk, so a chunk of an isometric map can be green when the view only touches
the corner of its box.

Use the "Orientation" knob to change the kind of map: orthogonal, isometric,
staggered or hexagonal.

The "Isometric, tall tiles" map has trees and rocks that are taller than their
cells, and are painted over the tiles behind them. Chunks would change which
tile is painted on top, so that map is split into runs instead: pieces of one
row, of up to four times the chunk size (64 tiles by default), which are drawn
in the same order as the tiles. The shapes are then the runs, which are long and
thin, and they reach up to fit the trees and rocks.

Press C, or use the "Culled" knob, to turn culling on and off. With culling off,
the small camera draws every chunk, so they are all green.

The FPS at the top is for the whole game. While the big view is on, it sets the
FPS, because it always draws the whole map. Press V, or use the "Big view" knob,
to hide the big view. Then the FPS is the FPS of the small camera alone.

The "Camera speed" knob changes how fast the small camera moves.

The "draw time" line is how long the small camera needs to draw the map in Dart.
It does not include the work of the GPU.
  ''';

  static final Vector2 _innerViewSize = Vector2(320, 240);
  static const _margin = 20.0;

  late final _TimedCamera _innerCamera;

  /// The small camera that moves around and that does the culling.
  CameraComponent get innerCamera => _innerCamera;

  bool _culled = culled;
  bool _bigView = bigView;
  late final TimedTiledComponent _culledMap;
  late final TimedTiledComponent _plainMap;
  late final CullingStatusText _statusText;
  late final World _emptyWorld;
  late final _ChunkGrid _grid;
  late final TextComponent _chunksText;
  late final TextComponent _timeText;
  double _time = 0;

  /// Whether the small camera skips the chunks that are out of its view.
  bool get isCulled => _culled;

  @override
  bool get culled => _culled;

  @override
  set culled(bool value) {
    if (value == _culled) {
      return;
    }
    if (!isLoaded) {
      _culled = value;
      return;
    }
    world.remove(_currentMap);
    _culled = value;
    world.add(_currentMap);
    _statusText.culled = value;
  }

  /// Whether the big view shows the whole map. When it is hidden, only the
  /// small camera draws the map.
  bool get bigView => _bigView;

  set bigView(bool value) {
    if (value == _bigView) {
      return;
    }
    _bigView = value;
    if (isLoaded) {
      camera.world = value ? world : _emptyWorld;
    }
  }

  /// The size of the map, in world units.
  Vector2 get mapSize => _culledMap.size;

  TimedTiledComponent get _currentMap => _culled ? _culledMap : _plainMap;

  @override
  Future<void> onLoad() async {
    // The same map twice, so that the key can switch between them instantly.
    _culledMap = await loadTiledCullingMap(orientation, chunkSize: chunkSize);
    _plainMap = await loadTiledCullingMap(orientation);
    world.addAll([_currentMap, _grid = _ChunkGrid(orientation, chunkSize)]);

    // The big camera looks at this empty world when the big view is hidden.
    _emptyWorld = World();
    add(_emptyWorld);
    camera.world = _bigView ? world : _emptyWorld;

    // The default camera is the big one, and it shows the whole map.
    camera.viewfinder
      ..visibleGameSize = mapSize * 1.02
      ..position = mapSize / 2;

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
            text: 'Green: ${_grid.unit} drawn by the small camera',
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
      culled = !culled;
      reportKnob(cullingCulledKnob, culled);
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyV) {
      bigView = !bigView;
      reportKnob(cullingBigViewKnob, bigView);
      return KeyEventResult.handled;
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt * cameraSpeed;
    final path = orientation.path + 0.05;
    innerCamera.viewfinder.position = Vector2(
      mapSize.x * (0.5 + cos(_time * 0.3) * path),
      mapSize.y * (0.5 + sin(_time * 0.2) * path),
    );
    _chunksText.text =
        'Small camera draws: '
        '${_grid.chunksInView}/${_grid.chunkCount} ${_grid.unit}';
    final milliseconds = _innerCamera.drawMilliseconds;
    if (milliseconds > 0) {
      _timeText.text =
          'Small camera draw time: ${milliseconds.toStringAsFixed(1)} ms';
    }
  }
}

/// Draws the chunks (or the runs) of the map, and fills the ones that the
/// small camera draws. It is only drawn by the big camera.
class _ChunkGrid(
  final TiledCullingOrientation orientation,
  final int chunkSize,
) extends Component with HasGameRef<TiledCullingVisualizedExample> {
  /// The last chunk of a row can be smaller than the others.
  late final int _chunksPerSide = (tiledCullingTiles / chunkSize).ceil();

  final Paint _linePaint = BasicPalette.white.withAlpha(70).paint()
    ..style = PaintingStyle.stroke;
  final Paint _fillPaint = Paint()..color = const Color(0x664DFF6A);
  final Paint _viewPaint = BasicPalette.white.paint()
    ..style = PaintingStyle.stroke;

  /// The smallest box around each chunk, which is what Flame compares with the
  /// view of the camera.
  final List<Rect> _bounds = [];

  /// The shape that is drawn for each chunk. The chunks of an isometric map are
  /// diamonds, and the others are drawn as their boxes.
  final List<Path> _shapes = [];

  this : super(priority: 1000);

  int get chunkCount => _bounds.length;

  /// What the parts of the map are called.
  String get unit => orientation.splitsInRuns ? 'runs' : 'chunks';

  /// How many chunks the small camera draws.
  int chunksInView = 0;

  @override
  void onMount() {
    super.onMount();
    // The lines have the same width on the screen for every size of map.
    final width = gameRef.mapSize.x / 3200;
    _linePaint.strokeWidth = width;
    _viewPaint.strokeWidth = width * 3;
    if (_bounds.isEmpty) {
      if (orientation.splitsInRuns) {
        _makeRuns();
      } else {
        _makeChunks();
      }
    }
  }

  /// The center of the cell of a tile, the way that Flame places the tiles.
  Offset _tileCenter(int tx, int ty) {
    final w = orientation.tileWidth;
    final h = orientation.tileHeight;
    final shift = ty.isOdd ? w / 2 : 0.0;
    return switch (orientation) {
      TiledCullingOrientation.orthogonal => Offset(
        (tx + 0.5) * w,
        (ty + 0.5) * h,
      ),
      TiledCullingOrientation.isometric ||
      TiledCullingOrientation.isometricTall => Offset(
        w / 2 * (tx - ty) + tiledCullingTiles * w / 2,
        h / 2 * (tx + ty) + h / 2,
      ),
      TiledCullingOrientation.staggered => Offset(
        tx * w + shift + w / 2,
        ty * h / 2 + h / 2,
      ),
      TiledCullingOrientation.hexagonal => Offset(
        tx * w + shift + w / 2,
        ty * h * 0.75 + h / 2,
      ),
    };
  }

  void _makeChunks() {
    final w = orientation.tileWidth;
    final h = orientation.tileHeight;
    for (var cy = 0; cy < _chunksPerSide; cy++) {
      for (var cx = 0; cx < _chunksPerSide; cx++) {
        final first = Offset(
          (cx * chunkSize).toDouble(),
          (cy * chunkSize).toDouble(),
        );
        final last = Offset(
          min(first.dx + chunkSize, tiledCullingTiles) - 1,
          min(first.dy + chunkSize, tiledCullingTiles) - 1,
        );
        var bounds = Rect.fromCenter(
          center: _tileCenter(first.dx.toInt(), first.dy.toInt()),
          width: w,
          height: h,
        );
        for (var ty = first.dy.toInt(); ty <= last.dy; ty++) {
          for (var tx = first.dx.toInt(); tx <= last.dx; tx++) {
            bounds = bounds.expandToInclude(
              Rect.fromCenter(center: _tileCenter(tx, ty), width: w, height: h),
            );
          }
        }
        _bounds.add(bounds);

        if (orientation.isIsometric) {
          final top = _tileCenter(first.dx.toInt(), first.dy.toInt());
          final right = _tileCenter(last.dx.toInt(), first.dy.toInt());
          final bottom = _tileCenter(last.dx.toInt(), last.dy.toInt());
          final left = _tileCenter(first.dx.toInt(), last.dy.toInt());
          _shapes.add(
            Path()
              ..moveTo(top.dx, top.dy - h / 2)
              ..lineTo(right.dx + w / 2, right.dy)
              ..lineTo(bottom.dx, bottom.dy + h / 2)
              ..lineTo(left.dx - w / 2, left.dy)
              ..close(),
          );
        } else {
          _shapes.add(Path()..addRect(bounds));
        }
      }
    }
  }

  /// The runs of an isometric map with tiles that are taller than the cells.
  ///
  /// A run is a piece of one row of tiles, which goes down and to the right on
  /// the screen. Each tile is drawn as a box as wide as the cell, and as high
  /// as its image, which sits on the bottom of the cell.
  void _makeRuns() {
    assert(orientation.isIsometric, 'Only isometric maps have tall tiles here');
    final w = orientation.tileWidth;
    final h = orientation.tileHeight;
    // How far the images reach above the cells.
    final raise = orientation.artHeight! - h;
    // The run length of Flame: four times the chunk size.
    final runLength = 4 * chunkSize;
    for (var ty = 0; ty < tiledCullingTiles; ty++) {
      for (var start = 0; start < tiledCullingTiles; start += runLength) {
        final end = min(start + runLength, tiledCullingTiles) - 1;
        final first = _tileCenter(start, ty);
        final last = _tileCenter(end, ty);
        final shape = Path()
          ..moveTo(first.dx - w / 2, first.dy - raise)
          ..lineTo(first.dx, first.dy - h / 2 - raise)
          ..lineTo(last.dx + w / 2, last.dy - raise)
          ..lineTo(last.dx + w / 2, last.dy)
          ..lineTo(last.dx, last.dy + h / 2)
          ..lineTo(first.dx - w / 2, first.dy)
          ..close();
        _shapes.add(shape);
        _bounds.add(shape.getBounds());
      }
    }
  }

  bool _isDrawn(Rect chunk, Rect view) =>
      !gameRef.isCulled || chunk.overlaps(view);

  @override
  void update(double dt) {
    final view = gameRef.innerCamera.visibleWorldRect;
    var inView = 0;
    for (final bounds in _bounds) {
      if (_isDrawn(bounds, view)) {
        inView++;
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
    for (var i = 0; i < _bounds.length; i++) {
      if (_isDrawn(_bounds[i], view)) {
        canvas.drawPath(_shapes[i], _fillPaint);
      }
      canvas.drawPath(_shapes[i], _linePaint);
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
