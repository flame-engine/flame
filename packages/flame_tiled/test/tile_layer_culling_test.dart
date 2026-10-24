import 'dart:math';
import 'dart:ui';

import 'package:flame/cache.dart';
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

/// The maps are in `test/assets`, where they can be opened in Tiled. They have
/// 64 x 64 tiles, which are 4 x 4 chunks of 16 x 16 tiles.
const _finite = 'culling_finite.tmx';
const _infinite = 'culling_infinite.tmx';

/// The same as [_infinite], but its chunks start at the tile (-32, -32).
const _infiniteNegative = 'culling_infinite_negative.tmx';

/// A map with tiles that are drawn with an offset.
const _tileOffset = 'culling_infinite_tile_offset.tmx';

/// A map with tiles that are bigger than its cells.
const _oversized = 'infinite_oversized_tiles_orthogonal.tmx';

const _tileSize = 16.0;

TestAssetBundle _bundle(String map) => TestAssetBundle(
  imageNames: ['0x72_DungeonTilesetII_v1.4.png'],
  stringNames: [map],
);

typedef _Loaded = ({FlameGame game, TiledComponent map, FlameTileLayer layer});

/// Loads the map [file], without adding it to a game.
Future<TiledComponent> _loadMap(
  String file, {
  int? chunkSize,
  CameraComponent? camera,
}) async {
  TiledAtlas.atlasMap.clear();
  final bundle = _bundle(file);
  Flame.bundle = bundle;
  return await TiledComponent.load(
    'assets/tiles/$file',
    Vector2.all(_tileSize),
    bundle: bundle,
    images: Images(bundle: bundle),
    chunkSize: chunkSize,
    camera: camera,
  );
}

FlameTileLayer _firstTileLayer(TiledComponent map) =>
    map.tileMap.renderableLayers.whereType<FlameTileLayer>().first;

/// Loads the map [file] and shows it through a camera that looks at
/// [cameraPosition].
Future<_Loaded> _load(
  String file, {
  Vector2? cameraPosition,
  Vector2? viewSize,
  int? chunkSize,
}) async {
  final size = viewSize ?? Vector2.all(100);
  final map = await _loadMap(file, chunkSize: chunkSize);
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
  return (game: game, map: map, layer: _firstTileLayer(map));
}

/// A game with a world and a camera that looks far away from the maps, so
/// that a map that is culled by it renders nothing.
Future<FlameGame> _gameLookingAway() async {
  final world = World();
  final camera = CameraComponent(
    world: world,
    viewport: FixedSizeViewport(100, 100),
  )..viewfinder.position = Vector2.all(-5000);
  final game = await initializeGame(
    () => FlameGame(world: world, camera: camera),
  );
  game.onGameResize(Vector2.all(100));
  return game;
}

void render(FlameGame game) => game.render(Canvas(PictureRecorder()));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(TiledAtlas.atlasMap.clear);

  group('culling of tile layers', () {
    test('an infinite map is split in the chunks of the map', () async {
      final loaded = await _load(_infinite);
      expect(loaded.layer.chunkCount, 16);
    });

    test('only the chunks in view are rendered', () async {
      // The view covers 100 x 100 units around (50, 50), which touches the
      // first chunk (256 x 256 units) only.
      final loaded = await _load(_infinite);
      render(loaded.game);
      expect(loaded.layer.renderedChunkCount, 1);
    });

    test('moving the camera changes the chunks that are rendered', () async {
      final loaded = await _load(_infinite);
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
      final loaded = await _load(_infiniteNegative);
      expect(loaded.layer.chunkCount, 16);

      loaded.game.camera.viewfinder.position = Vector2(-500, -500);
      render(loaded.game);
      expect(loaded.layer.renderedChunkCount, 1);
    });

    test('everything is rendered when there is no camera', () async {
      // Not added to a game, so there is no camera to look through.
      TiledAtlas.atlasMap.clear();
      final bundle = _bundle(_infinite);
      final map = await TiledComponent.load(
        'assets/tiles/$_infinite',
        Vector2.all(_tileSize),
        bundle: bundle,
        images: Images(bundle: bundle),
      );
      map.tileMap.renderTree(Canvas(PictureRecorder()));

      final layer = map.tileMap.renderableLayers.single as FlameTileLayer;
      expect(layer.chunkCount, 16);
      expect(layer.renderedChunkCount, 16);
    });

    test('a finite map is not split by default', () async {
      final loaded = await _load(_finite);
      expect(loaded.layer.chunkCount, 0);
    });

    test('a finite map is split when asked', () async {
      final loaded = await _load(
        _finite,
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
      final finite = await _load(_finite, chunkSize: 8);
      expect(finite.layer.chunkCount, 64);

      // The chunks of the infinite map are 16 x 16 tiles, in the file.
      final infinite = await _load(_infinite, chunkSize: 32);
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
          _finite,
          cameraPosition: position,
          viewSize: viewSize,
          chunkSize: 16,
        );
        final whole = await _load(
          _finite,
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
        _finite,
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

    test('only the layers with tiles that stick out are not split', () async {
      // The "Floor" layer only uses the tileset of 16 x 16 tiles, and the
      // "Walls" layer also uses the tileset of 32 x 32 tiles.
      final loaded = await _load(_oversized);
      final layers = loaded.map.tileMap.renderableLayers
          .whereType<FlameTileLayer>();
      final floor = layers.singleWhere((layer) => layer.layer.name == 'Floor');
      final walls = layers.singleWhere((layer) => layer.layer.name == 'Walls');
      expect(floor.usesChunks, isTrue);
      expect(floor.chunkCount, greaterThan(0));
      expect(walls.usesChunks, isFalse);
      expect(walls.chunkCount, 0);
    });

    test('tiles with an offset are not split', () async {
      final loaded = await _load(
        _tileOffset,
      );
      expect(loaded.layer.chunkCount, 0);
    });

    test('a map in the viewport of a camera is not culled', () async {
      final game = await _gameLookingAway();
      final map = await _loadMap(_infinite);
      await game.camera.viewport.ensureAdd(map);
      render(game);

      final layer = _firstTileLayer(map);
      expect(layer.chunkCount, 16);
      expect(layer.renderedChunkCount, 16);
    });

    test('a map that is added to the game directly is not culled', () async {
      final game = await _gameLookingAway();
      final map = await _loadMap(_infinite);
      await game.ensureAdd(map);
      render(game);

      final layer = _firstTileLayer(map);
      expect(layer.chunkCount, 16);
      expect(layer.renderedChunkCount, 16);
    });

    test('a map is not culled by the view of another camera', () async {
      // The map follows the parallax of a camera that is not the one that
      // renders it, so the view of that camera is not what is shown.
      final game = await _gameLookingAway();
      // Its world is not in the game, so this camera does not render anything.
      final other = CameraComponent(world: World())
        ..viewfinder.position = Vector2.all(5000);
      await game.ensureAdd(other);
      final map = await _loadMap(_infinite, camera: other);
      await game.world.ensureAdd(map);
      render(game);

      final layer = _firstTileLayer(map);
      expect(layer.renderedChunkCount, 16);
    });

    test('a map in the world is culled by the camera of the game', () async {
      final game = await _gameLookingAway();
      final map = await _loadMap(_infinite);
      await game.world.ensureAdd(map);
      render(game);

      expect(_firstTileLayer(map).renderedChunkCount, 0);
    });

    test('a tile that is handed out stays visible when moved away', () async {
      final loaded = await _load(_infinite);
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
          _infinite,
          cameraPosition: position,
          viewSize: viewSize,
        );
        final finite = await _load(
          _finite,
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
        _infinite,
        cameraPosition: Vector2(400, 400),
        viewSize: viewSize,
      );
      final finite = await _load(
        _finite,
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
