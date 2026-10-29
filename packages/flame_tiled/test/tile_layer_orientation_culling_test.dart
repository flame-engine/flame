import 'package:flame/cache.dart';
import 'package:flame/camera.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_chunk.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_layer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_asset_bundle.dart';
import 'test_image_utils.dart';

/// The size of the chunks that the layers are split in, in tiles.
const _chunkSize = 3;

/// The width of a tile, and of a cell of the maps.
const _cellWidth = 16.0;

/// A kind of map of the tests below.
///
/// The maps are in `test/assets`, where they can be opened in Tiled. A map of
/// 10 x 10 tiles is `culling_<id>.tmx`. The art of the tiles is shaped like the
/// cells of the map (a diamond or a hexagon), and it stays inside of its cell
/// and doesn't touch the art of the neighbors, like the art of a map that is
/// made for Tiled. That way the order that tiles are painted in doesn't matter.
///
/// The files of a kind of map are:
///  - `culling_<id>.tmx`, a finite map.
///  - `culling_<id>_quarter_turns.tmx`, the same map with tiles that are turned
///    a quarter (only for some kinds).
///  - `culling_infinite_<id>.tmx`, an infinite map with chunks of 5 x 5 tiles
///    that start at the tile (0, 0), and `culling_infinite_<id>_negative.tmx`,
///    which starts at (-5, -5) (only for some kinds).
class _Config({
  required final String id,
  required final String name,

  /// The tileset image of the map.
  required final String image,
  final double cellHeight = 16,
}) {
  String get file => 'culling_$id.tmx';
  String get quarterTurnsFile => 'culling_${id}_quarter_turns.tmx';
  String infiniteFile({required bool negative}) =>
      'culling_infinite_$id${negative ? '_negative' : ''}.tmx';
}

const _diamonds = 'culling_diamonds_16x16.png';
const _hexagonsPointy = 'culling_hexagons_pointy.png';
const _hexagonsFlat = 'culling_hexagons_flat.png';

final _isometric = _Config(
  id: 'isometric',
  name: 'isometric',
  image: _diamonds,
);

final _staggeredXOdd = _Config(
  id: 'staggered_x_odd',
  name: 'staggered x odd',
  image: _diamonds,
);

final _hexagonalPointyOdd = _Config(
  id: 'hexagonal_pointy_odd',
  name: 'hexagonal pointy odd',
  image: _hexagonsPointy,
);

final _hexagonalFlatOdd = _Config(
  id: 'hexagonal_flat_odd',
  name: 'hexagonal flat odd',
  image: _hexagonsFlat,
);

/// Cells that are not square, like the tiles of an isometric map.
final _isometric2To1 = _Config(
  id: 'isometric_2_1',
  name: 'isometric, 16x8 cells',
  image: 'culling_diamonds_16x8.png',
  cellHeight: 8,
);

final _configs = [
  _isometric,
  _staggeredXOdd,
  _Config(
    id: 'staggered_x_even',
    name: 'staggered x even',
    image: _diamonds,
  ),
  _Config(
    id: 'staggered_y_odd',
    name: 'staggered y odd',
    image: _diamonds,
  ),
  _Config(
    id: 'staggered_y_even',
    name: 'staggered y even',
    image: _diamonds,
  ),
  _hexagonalPointyOdd,
  _Config(
    id: 'hexagonal_pointy_even',
    name: 'hexagonal pointy even',
    image: _hexagonsPointy,
  ),
  _hexagonalFlatOdd,
  _Config(
    id: 'hexagonal_flat_even',
    name: 'hexagonal flat even',
    image: _hexagonsFlat,
  ),
  _isometric2To1,
  _Config(
    id: 'staggered_x_odd_2_1',
    name: 'staggered x odd, 16x8 cells',
    image: 'culling_diamonds_16x8.png',
    cellHeight: 8,
  ),
];

Future<TiledComponent> _loadFile(
  String file,
  _Config config, {
  int? chunkSize,
}) async {
  // The atlas is cached by the name of the image.
  TiledAtlas.atlasMap.clear();
  final bundle = TestAssetBundle(
    imageNames: [config.image],
    stringNames: [file],
  );
  Flame.bundle = bundle;
  return await TiledComponent.load(
    'assets/tiles/$file',
    Vector2(_cellWidth, config.cellHeight),
    bundle: bundle,
    images: Images(bundle: bundle),
    chunkSize: chunkSize,
  );
}

Future<TiledComponent> _load(
  _Config config, {
  int? chunkSize,
  bool quarterTurns = false,
}) => _loadFile(
  quarterTurns ? config.quarterTurnsFile : config.file,
  config,
  chunkSize: chunkSize,
);

Future<TiledComponent> _loadInfinite(
  _Config config, {
  required bool negative,
  int? chunkSize,
}) => _loadFile(
  config.infiniteFile(negative: negative),
  config,
  chunkSize: chunkSize,
);

FlameTileLayer _layerOf(TiledComponent component) =>
    component.tileMap.renderableLayers.single as FlameTileLayer;

Iterable<FlameTileLayer> _tileLayersOf(TiledComponent component) =>
    component.tileMap.renderableLayers.whereType<FlameTileLayer>();

/// Shows [component] through a camera that looks at [position].
Future<FlameGame> _show(
  TiledComponent component,
  Vector2 position,
  Vector2 viewSize,
) async {
  final world = World();
  final camera = CameraComponent(
    world: world,
    viewport: FixedSizeViewport(viewSize.x, viewSize.y),
  )..viewfinder.position = position;
  final game = await initializeGame(
    () => FlameGame(world: world, camera: camera),
  );
  game.onGameResize(viewSize);
  await world.ensureAdd(component);
  game.update(0);
  return game;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(TiledAtlas.atlasMap.clear);

  for (final config in _configs) {
    group('culling of ${config.name} maps', () {
      test('splits the layer in chunks', () async {
        final component = await _load(config, chunkSize: _chunkSize);
        // 10 tiles in chunks of 3 tiles.
        expect(_layerOf(component).chunkCount, greaterThan(4));
      });

      test('does not split the layer by default', () async {
        final component = await _load(config);
        expect(_layerOf(component).chunkCount, 0);
      });

      test('renders what it renders unsplit, without a camera', () async {
        final whole = await _load(config);
        final split = await _load(config, chunkSize: _chunkSize);

        expect(
          await renderMapToPng(split),
          orderedEquals(await renderMapToPng(whole)),
        );
        expect(
          _layerOf(split).renderedChunkCount,
          _layerOf(split).chunkCount,
        );
      });

      test('renders what it renders unsplit, through a camera', () async {
        final viewSize = Vector2(70, 60);
        for (final position in [
          Vector2(40, 30),
          Vector2(80, 80),
          Vector2(130, 50),
          Vector2(50, 120),
          Vector2(160, 160),
        ]) {
          final whole = await _show(await _load(config), position, viewSize);
          final split = await _show(
            await _load(config, chunkSize: _chunkSize),
            position,
            viewSize,
          );

          expect(
            await renderGameToPng(split),
            orderedEquals(await renderGameToPng(whole)),
            reason: 'camera at $position',
          );
        }
      });

      test('skips the chunks that are out of view', () async {
        final component = await _load(config, chunkSize: _chunkSize);
        final game = await _show(component, Vector2(20, 20), Vector2(50, 50));
        await renderGameToPng(game);

        final layer = _layerOf(component);
        expect(layer.renderedChunkCount, greaterThan(0));
        expect(layer.renderedChunkCount, lessThan(layer.chunkCount));
      });

      test('keeps the chunk of a tile that was handed out rendered', () async {
        final component = await _load(config, chunkSize: _chunkSize);
        final stack = component.tileMap.tileStack(1, 0, all: true);
        expect(stack.length, 1);

        // Far away from the map, nothing is in view.
        final game = await _show(
          component,
          Vector2(1000, 1000),
          Vector2(30, 30),
        );
        await renderGameToPng(game);
        expect(_layerOf(component).renderedChunkCount, 1);

        final other = await _load(config, chunkSize: _chunkSize);
        final otherGame = await _show(
          other,
          Vector2(1000, 1000),
          Vector2(30, 30),
        );
        await renderGameToPng(otherGame);
        expect(_layerOf(other).renderedChunkCount, 0);
      });
    });
  }

  group('culling of maps with cells that are not square', () {
    test('uses chunks when no tile is turned a quarter', () async {
      final component = await _load(_isometric2To1, chunkSize: _chunkSize);
      expect(_layerOf(component).split, TileLayerSplit.chunks);
      expect(_layerOf(component).chunkCount, greaterThan(4));
    });

    test('uses runs when a tile is turned a quarter', () async {
      // A turned tile of 16 x 8 units is 8 x 16 units, which sticks out of its
      // cell.
      final whole = await _load(_isometric2To1, quarterTurns: true);
      final split = await _load(
        _isometric2To1,
        chunkSize: _chunkSize,
        quarterTurns: true,
      );
      expect(_layerOf(split).split, TileLayerSplit.runs);
      expect(_layerOf(split).chunkCount, greaterThan(4));
      expect(
        await renderMapToPng(split),
        orderedEquals(await renderMapToPng(whole)),
      );
    });

    test('uses runs when a tile is turned a quarter after loading', () async {
      Future<TiledComponent> loadTurned({int? chunkSize}) async {
        final component = await _load(_isometric2To1, chunkSize: chunkSize);
        component.tileMap.setTileData(
          layerId: _layerOf(component).layer.id!,
          x: 4,
          y: 4,
          gid: Gid(1, const Flips.defaults().copyWith(diagonally: true)),
        );
        return component;
      }

      final split = await _load(_isometric2To1, chunkSize: _chunkSize);
      expect(_layerOf(split).split, TileLayerSplit.chunks);

      final turned = await loadTurned(chunkSize: _chunkSize);
      expect(_layerOf(turned).split, TileLayerSplit.runs);
      expect(_layerOf(turned).chunkCount, greaterThan(4));
      expect(
        await renderMapToPng(turned),
        orderedEquals(await renderMapToPng(await loadTurned())),
      );
    });

    test('uses chunks for square cells with tiles turned a quarter', () async {
      final component = await _load(
        _isometric,
        chunkSize: _chunkSize,
        quarterTurns: true,
      );
      expect(_layerOf(component).split, TileLayerSplit.chunks);
      expect(_layerOf(component).chunkCount, greaterThan(4));
    });
  });

  group('culling of infinite maps of other orientations', () {
    // Chunks of 5 x 5 tiles, which is what the maps below are made of, against
    // another way to divide the same tiles.
    final configs = [
      _isometric,
      _staggeredXOdd,
      _hexagonalPointyOdd,
      _hexagonalFlatOdd,
    ];
    const region = Rect.fromLTWH(-300, -300, 800, 800);

    for (final config in configs) {
      test('uses the chunks of the map (${config.name})', () async {
        final component = await _loadInfinite(config, negative: false);
        // 10 tiles in chunks of 5 tiles.
        expect(_layerOf(component).chunkCount, 4);
      });

      test('renders the same with other chunks (${config.name})', () async {
        for (final (negative, chunkSize) in [
          (false, 1000),
          (false, 3),
          (true, 3),
        ]) {
          final fromFile = await _loadInfinite(config, negative: negative);
          final other = await _loadInfinite(
            config,
            negative: negative,
            chunkSize: chunkSize,
          );

          expect(
            await renderMapRegionToPng(other.tileMap, region),
            orderedEquals(await renderMapRegionToPng(fromFile.tileMap, region)),
            reason:
                'chunks of $chunkSize tiles, '
                '${negative ? 'from a negative tile' : 'from tile 0'}',
          );
        }
      });
    }
  });

  group('culling of maps of the dungeon tileset', () {
    // The tiles of these maps are as big as their cells, and some of them are
    // animated.
    for (final mapType in ['hexagonal', 'isometric', 'staggered']) {
      test('renders what it renders unsplit ($mapType)', () async {
        Future<TiledComponent> load({int? chunkSize}) async {
          final bundle = TestAssetBundle(
            imageNames: ['0x72_DungeonTilesetII_v1.4.png'],
            stringNames: ['dungeon_animation_$mapType.tmx'],
          );
          Flame.bundle = bundle;
          return await TiledComponent.load(
            'assets/tiles/dungeon_animation_$mapType.tmx',
            Vector2.all(16),
            bundle: bundle,
            images: Images(bundle: bundle),
            chunkSize: chunkSize,
          );
        }

        final whole = await load();
        final split = await load(chunkSize: 1);
        expect(
          _tileLayersOf(split).map((layer) => layer.chunkCount),
          contains(greaterThan(1)),
        );

        // Compare the first frames of the animations too.
        for (final time in [0.0, 0.2, 0.4]) {
          whole.tileMap.updateTree(time);
          split.tileMap.updateTree(time);
          expect(
            await renderMapToPng(split),
            orderedEquals(await renderMapToPng(whole)),
            reason: 'after $time seconds',
          );
        }
      });
    }
  });

  group('culling of maps with tiles that stick out of their cell', () {
    Future<TiledComponent> loadAsset(
      String map,
      List<String> images, {
      int? chunkSize,
    }) async {
      final bundle = TestAssetBundle(imageNames: images, stringNames: [map]);
      Flame.bundle = bundle;
      return await TiledComponent.load(
        'assets/tiles/$map',
        Vector2(64, 32),
        bundle: bundle,
        images: Images(bundle: bundle),
        chunkSize: chunkSize,
      );
    }

    // The render of these maps is compared in tile_layer_run_culling_test.dart.
    test('splits an isometric map with taller tiles in runs', () async {
      final component = await loadAsset(
        'test_isometric.tmx',
        ['isometric_spritesheet.png'],
        chunkSize: 2,
      );
      expect(_tileLayersOf(component), isNotEmpty);
      expect(
        _tileLayersOf(component).map((l) => l.split),
        contains(TileLayerSplit.runs),
      );
    });

    test('splits a staggered map with taller tiles in runs', () async {
      final component = await loadAsset(
        'iso_staggered_overlap_y_odd.tmx',
        ['dirt_atlas.png'],
        chunkSize: 2,
      );
      expect(_tileLayersOf(component), isNotEmpty);
      expect(
        _tileLayersOf(component).map((l) => l.split),
        contains(TileLayerSplit.runs),
      );
    });
  });
}
