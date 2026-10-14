import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;

class TiledCullingExample({
  final bool culled = true,
}) extends FlameGame with KeyboardEvents {
  static const description = '''
The camera slowly moves over a big Tiled map, with 160,000 tiles in each of its
two layers. Press C, or use the "Culled" knob, to turn culling on and off.

With culling on, the map is split into chunks of 16 x 16 tiles (the `chunkSize`
of the map), and only the chunks that are in view are drawn. With culling off,
every tile of the map is drawn on every frame, even though only a few of them
are on-screen.

The "Map draw time" line is how long the map needs to draw in Dart. It does not
include the work of the GPU. Compare it, and the frame rate, with culling on and
off.
  ''';

  late bool _culled = culled;
  late final TimedTiledComponent _culledMap;
  late final TimedTiledComponent _plainMap;
  late final CullingStatusText _statusText;
  late final TextComponent _timeText;
  double _time = 0;

  TimedTiledComponent get _currentMap => _culled ? _culledMap : _plainMap;

  @override
  Future<void> onLoad() async {
    // The same map twice, so that the key can switch between them instantly.
    _culledMap = await loadTiledCullingMap(culled: true);
    _plainMap = await loadTiledCullingMap(culled: false);
    world.add(_currentMap);

    camera.viewport.add(
      PositionComponent(
        position: Vector2.all(10),
        size: Vector2(430, 130),
        children: [
          RectangleComponent(
            size: Vector2(430, 130),
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
          _timeText = TextComponent(
            position: Vector2(10, 70),
            textRenderer: cullingHudText,
          ),
          TextComponent(
            text: 'Press C to turn culling on or off',
            position: Vector2(10, 98),
            textRenderer: cullingHudText,
          ),
        ],
      ),
    );
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
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    const center = tiledCullingMapSize / 2;
    camera.viewfinder.position = Vector2(
      center + cos(_time * 0.3) * tiledCullingMapSize * 0.3,
      center + sin(_time * 0.2) * tiledCullingMapSize * 0.3,
    );
    final milliseconds = _currentMap.drawMilliseconds;
    if (milliseconds > 0) {
      _timeText.text = 'Map draw time: ${milliseconds.toStringAsFixed(1)} ms';
    }
  }
}

/// The number of tiles on each side of the map of the culling examples.
const tiledCullingTiles = 400;

/// The size that a tile is drawn with in the culling examples.
const tiledCullingTileSize = 32.0;

/// The size of the chunks, in tiles, that the culled map is split in.
const tiledCullingChunkSize = 16;

/// The size of the map of the culling examples, in pixels.
const tiledCullingMapSize = tiledCullingTiles * tiledCullingTileSize;

/// Loads the map of the culling examples (`culling_map.tmx`), which is
/// [tiledCullingTiles] tiles wide and high. It has a floor, with some details
/// on it, and the details are in a second layer.
///
/// The map is split in chunks, which are skipped while they are out of view,
/// when [culled] is true.
Future<TimedTiledComponent> loadTiledCullingMap({required bool culled}) async {
  final map = await RenderableTiledMap.fromFile(
    'assets/tiles/culling_map.tmx',
    Vector2.all(tiledCullingTileSize),
    chunkSize: culled ? tiledCullingChunkSize : null,
  );
  return TimedTiledComponent(map);
}

/// A [TiledComponent] that measures how long it takes to draw the map.
class TimedTiledComponent(super.tileMap) extends TiledComponent {
  final Stopwatch _stopwatch = Stopwatch();

  /// The average time that the map takes to draw, in milliseconds.
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

/// The text style of the HUD of the culling examples.
final TextPaint cullingHudText = TextPaint(
  style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 20),
);

/// Shows if culling is on (green) or off (red).
class CullingStatusText({
  bool culled = true,
  super.position,
}) extends TextComponent {
  static final _onText = TextPaint(
    style: const TextStyle(
      color: Color(0xFF4DFF6A),
      fontSize: 26,
      fontWeight: FontWeight.bold,
    ),
  );
  static final _offText = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFF5252),
      fontSize: 26,
      fontWeight: FontWeight.bold,
    ),
  );

  this : super(text: _label(culled), textRenderer: _style(culled));

  static String _label(bool culled) => culled ? 'Culling: ON' : 'Culling: OFF';

  static TextPaint _style(bool culled) => culled ? _onText : _offText;

  set culled(bool value) {
    text = _label(value);
    textRenderer = _style(value);
  }
}
