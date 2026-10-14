import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_layer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_asset_bundle.dart';
import 'test_image_utils.dart';

/// Tiles per side of the maps below, 4 x 4 chunks of 16 x 16 tiles.
const _tiles = 64;
const _tileSize = 16.0;

/// Gids that are different from each other, so that the pixels reveal whether
/// the right tile was drawn at the right place.
int _gid(int x, int y) => 1 + (x * 31 + y * 17) % 1000;

/// A map of [_tiles] x [_tiles] tiles. If it is infinite, its chunks start at
/// [origin].
String _mapXml({
  required bool infinite,
  int origin = 0,
  int tileSize = 16,
  String tilesetExtra = '',
}) {
  String csv(int x0, int y0, int width, int height) => [
    for (var y = 0; y < height; y++)
      [for (var x = 0; x < width; x++) _gid(x0 + x, y0 + y)].join(','),
  ].join(',\n');

  final String data;
  if (infinite) {
    String chunk(int cx, int cy) {
      final attributes = 'x="${origin + cx}" y="${origin + cy}"';
      final rows = csv(cx, cy, 16, 16);
      return '<chunk $attributes width="16" height="16">\n$rows\n</chunk>';
    }

    data = [
      for (var cy = 0; cy < _tiles; cy += 16)
        for (var cx = 0; cx < _tiles; cx += 16) chunk(cx, cy),
    ].join('\n');
  } else {
    data = csv(0, 0, _tiles, _tiles);
  }
  return '''
<?xml version="1.0" encoding="UTF-8"?>
<map version="1.8" orientation="orthogonal" renderorder="right-down" width="$_tiles" height="$_tiles" tilewidth="16" tileheight="16" infinite="${infinite ? 1 : 0}" nextlayerid="2" nextobjectid="1">
 <tileset firstgid="1" name="0x72" tilewidth="$tileSize" tileheight="$tileSize" tilecount="1024" columns="32">
  $tilesetExtra
  <image source="0x72_DungeonTilesetII_v1.4.png" width="512" height="512"/>
 </tileset>
 <layer id="1" name="Tiles" width="$_tiles" height="$_tiles">
  <data encoding="csv">
$data
  </data>
 </layer>
</map>
''';
}

class _MapBundle(final String map) extends TestAssetBundle {
  this
    : super(
        imageNames: ['0x72_DungeonTilesetII_v1.4.png'],
        stringNames: const [],
      );

  @override
  Future<String> loadString(String key, {bool cache = true}) async => map;
}

typedef _Loaded = ({FlameGame game, TiledComponent map, FlameTileLayer layer});

/// Loads the map and shows it through a camera that looks at [cameraPosition].
Future<_Loaded> _load(
  String xml, {
  Vector2? cameraPosition,
  Vector2? viewSize,
  int? chunkSize,
}) async {
  final size = viewSize ?? Vector2.all(100);
  TiledAtlas.atlasMap.clear();
  Flame.bundle = _MapBundle(xml);
  final map = await TiledComponent.load(
    'assets/tiles/map.tmx',
    Vector2.all(_tileSize),
    chunkSize: chunkSize,
  );
  final world = World();
  final camera = CameraComponent(
    world: world,
    viewport: FixedSizeViewport(size.x, size.y),
  )..viewfinder.position = cameraPosition ?? Vector2.all(50);
  final game = await initializeGame(
    () => FlameGame(world: world, camera: camera),
  );
  game.onGameResize(size);
  await world.ensureAdd(map);
  game.update(0);
  return (
    game: game,
    map: map,
    layer: map.tileMap.renderableLayers.single as FlameTileLayer,
  );
}

void render(FlameGame game) => game.render(Canvas(PictureRecorder()));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(TiledAtlas.atlasMap.clear);

  group('culling of tile layers', () {
    test('an infinite map is split in the chunks of the map', () async {
      final loaded = await _load(_mapXml(infinite: true));
      expect(loaded.layer.chunkCount, 16);
    });

    test('only the chunks in view are rendered', () async {
      // The view covers 100 x 100 units around (50, 50), which touches the
      // first chunk (256 x 256 units) only.
      final loaded = await _load(_mapXml(infinite: true));
      render(loaded.game);
      expect(loaded.layer.renderedChunkCount, 1);
    });

    test('moving the camera changes the chunks that are rendered', () async {
      final loaded = await _load(_mapXml(infinite: true));
      loaded.game.camera.viewfinder.position = Vector2(256, 256);
      render(loaded.game);
      expect(loaded.layer.renderedChunkCount, 4);

      loaded.game.camera.viewfinder.position = Vector2(1000, 1000);
      render(loaded.game);
      expect(loaded.layer.renderedChunkCount, 1);

      loaded.game.camera.viewfinder.position = Vector2(-5000, 0);
      render(loaded.game);
      expect(loaded.layer.renderedChunkCount, 0);
    });

    test('chunks at negative coordinates are culled too', () async {
      final loaded = await _load(_mapXml(infinite: true, origin: -32));
      expect(loaded.layer.chunkCount, 16);

      loaded.game.camera.viewfinder.position = Vector2(-500, -500);
      render(loaded.game);
      expect(loaded.layer.renderedChunkCount, 1);
    });

    test('everything is rendered when there is no camera', () async {
      // Not added to a game, so there is no camera to look through.
      Flame.bundle = _MapBundle(_mapXml(infinite: true));
      TiledAtlas.atlasMap.clear();
      final map = await TiledComponent.load(
        'assets/tiles/map.tmx',
        Vector2.all(_tileSize),
      );
      map.tileMap.renderTree(Canvas(PictureRecorder()));

      final layer = map.tileMap.renderableLayers.single as FlameTileLayer;
      expect(layer.chunkCount, 16);
      expect(layer.renderedChunkCount, 16);
    });

    test('a finite map is not split by default', () async {
      final loaded = await _load(_mapXml(infinite: false));
      expect(loaded.layer.chunkCount, 0);
    });

    test('a finite map is split when asked', () async {
      final loaded = await _load(
        _mapXml(infinite: false),
        chunkSize: 16,
      );
      expect(loaded.layer.chunkCount, 16);

      render(loaded.game);
      expect(loaded.layer.renderedChunkCount, 1);

      loaded.game.camera.viewfinder.position = Vector2(256, 256);
      render(loaded.game);
      expect(loaded.layer.renderedChunkCount, 4);
    });

    test('the chunk size can be changed', () async {
      final finite = await _load(_mapXml(infinite: false), chunkSize: 8);
      expect(finite.layer.chunkCount, 64);

      // The chunks of the infinite map are 16 x 16 tiles, in the file.
      final infinite = await _load(_mapXml(infinite: true), chunkSize: 32);
      expect(infinite.layer.chunkCount, 4);

      render(infinite.game);
      expect(infinite.layer.renderedChunkCount, 1);
    });

    test('a finite map that is split renders what it did before', () async {
      for (final position in [
        Vector2(50, 50),
        Vector2(256, 256),
        Vector2(333, 120),
        Vector2(900, 900),
      ]) {
        final viewSize = Vector2(300, 200);
        final split = await _load(
          _mapXml(infinite: false),
          cameraPosition: position,
          viewSize: viewSize,
          chunkSize: 16,
        );
        final whole = await _load(
          _mapXml(infinite: false),
          cameraPosition: position,
          viewSize: viewSize,
        );

        final a = await renderGameToPng(split.game);
        final b = await renderGameToPng(whole.game);
        expect(a, orderedEquals(b), reason: 'camera at $position');
      }
    });

    test('changing a tile of a split finite map rebuilds its chunks', () async {
      final loaded = await _load(
        _mapXml(infinite: false),
        chunkSize: 16,
      );
      loaded.map.tileMap.setTileData(
        layerId: 1,
        x: 0,
        y: 0,
        gid: const Gid(2, Flips.defaults()),
      );
      expect(loaded.layer.chunkCount, 16);

      render(loaded.game);
      expect(loaded.layer.renderedChunkCount, 1);
    });

    test('tiles that stick out of their cell are not split', () async {
      final loaded = await _load(_mapXml(infinite: true, tileSize: 32));
      expect(loaded.layer.chunkCount, 0);
    });

    test('tiles with an offset are not split', () async {
      final loaded = await _load(
        _mapXml(infinite: true, tilesetExtra: '<tileoffset x="3" y="3"/>'),
      );
      expect(loaded.layer.chunkCount, 0);
    });

    test('a tile that is handed out stays visible when moved away', () async {
      final loaded = await _load(_mapXml(infinite: true));
      final stack = loaded.map.tileMap.tileStack(0, 0, all: true);
      expect(stack.length, 1);

      // Look at the chunks far from the chunk that has the tile in it.
      loaded.game.camera.viewfinder.position = Vector2(700, 700);
      render(loaded.game);
      expect(loaded.layer.renderedChunkCount, 2);
    });

    test('renders exactly what the same finite map renders', () async {
      for (final position in [
        Vector2(50, 50),
        Vector2(256, 256),
        Vector2(333, 120),
        Vector2(900, 900),
      ]) {
        final viewSize = Vector2(300, 200);
        final infinite = await _load(
          _mapXml(infinite: true),
          cameraPosition: position,
          viewSize: viewSize,
        );
        final finite = await _load(
          _mapXml(infinite: false),
          cameraPosition: position,
          viewSize: viewSize,
        );

        final a = await renderGameToPng(infinite.game);
        final b = await renderGameToPng(finite.game);
        expect(a, orderedEquals(b), reason: 'camera at $position');
      }
    });

    test('a rotated camera does not hide tiles that are visible', () async {
      final viewSize = Vector2(300, 200);
      final infinite = await _load(
        _mapXml(infinite: true),
        cameraPosition: Vector2(400, 400),
        viewSize: viewSize,
      );
      final finite = await _load(
        _mapXml(infinite: false),
        cameraPosition: Vector2(400, 400),
        viewSize: viewSize,
      );
      infinite.game.camera.viewfinder.angle = pi / 5;
      finite.game.camera.viewfinder.angle = pi / 5;

      final a = await renderGameToPng(infinite.game);
      final b = await renderGameToPng(finite.game);
      expect(a, orderedEquals(b));
    });
  });
}
