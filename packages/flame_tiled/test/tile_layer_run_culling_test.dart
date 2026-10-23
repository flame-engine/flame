import 'dart:io';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_chunk.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_layer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_asset_bundle.dart';
import 'test_image_utils.dart';

/// Maps from `test/assets` with tiles that stick out of their cells: tiles
/// that are bigger than the cells, flipped and rotated, with an offset, or
/// hexagons that are taller than the rows. Their layers are split in runs.
const _maps = [
  'oversized_demo_orthogonal.tmx',
  'oversized_demo_isometric.tmx',
  'oversized_demo_staggered.tmx',
  'oversized_demo_hexagonal.tmx',
  'oversized_demo_flips_orthogonal.tmx',
  'oversized_demo_flips_isometric.tmx',
  'oversized_demo_flips_staggered.tmx',
  'oversized_demo_flips_hexagonal.tmx',
  'oversized_tiles_orthogonal.tmx',
  'oversized_tiles_isometric.tmx',
  'oversized_tiles_staggered.tmx',
  'oversized_tiles_hexagonal.tmx',
  'iso_staggered_overlap_x_even.tmx',
  'iso_staggered_overlap_x_odd.tmx',
  'iso_staggered_overlap_y_even.tmx',
  'iso_staggered_overlap_y_odd.tmx',
  'test_isometric.tmx',
  'test_shifted.tmx',
  'test_tile_offset_orthogonal.tmx',
  'test_tile_offset_isometric.tmx',
  'test_tile_offset_staggered.tmx',
  'test_tile_offset_hexagonal.tmx',
  'flat_hex_even.tmx',
  'flat_hex_odd.tmx',
  'pointy_hex_even.tmx',
  'pointy_hex_odd.tmx',
];

/// Loads [map] from `test/assets`, with every image that it uses.
Future<TiledComponent> _load(String map, {int? chunkSize}) async {
  // The atlas is cached by the name of the image.
  TiledAtlas.atlasMap.clear();
  final contents = File('test/assets/$map').readAsStringSync();
  final images = RegExp('<image source="([^"]+)"')
      .allMatches(contents)
      .map((match) => match.group(1)!)
      .toSet()
      .toList();
  final mapElement = RegExp('<map [^>]*>').firstMatch(contents)!.group(0)!;
  double attribute(String name) => double.parse(
    RegExp('$name="([0-9]+)"').firstMatch(mapElement)!.group(1)!,
  );

  final bundle = TestAssetBundle(imageNames: images, stringNames: [map]);
  Flame.bundle = bundle;
  return await TiledComponent.load(
    'assets/tiles/$map',
    Vector2(attribute('tilewidth'), attribute('tileheight')),
    bundle: bundle,
    images: Images(bundle: bundle),
    chunkSize: chunkSize,
  );
}

Iterable<FlameTileLayer> _tileLayersOf(TiledComponent component) =>
    component.tileMap.renderableLayers.whereType<FlameTileLayer>();

/// Waits for the batches to finish making the flipped versions of their
/// atlases. Until then a batch draws its flipped tiles without the atlas.
Future<void> _settle() => Flame.images.ready();

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

  group('culling of maps with tiles that stick out of their cell', () {
    for (final map in _maps) {
      test('splits the layers with tall tiles in runs ($map)', () async {
        final component = await _load(map, chunkSize: 2);
        final layers = _tileLayersOf(component);
        expect(layers, isNotEmpty);
        // Layers that only use tiles as big as the cells use chunks.
        expect(
          layers.map((layer) => layer.split),
          everyElement(isNot(TileLayerSplit.none)),
        );
        expect(
          layers.map((layer) => layer.split),
          contains(TileLayerSplit.runs),
        );
        expect(
          layers.map((layer) => layer.chunkCount),
          contains(greaterThan(1)),
        );
      });

      test('renders what it renders unsplit ($map)', () async {
        final whole = await _load(map);
        expect(
          _tileLayersOf(whole).map((layer) => layer.split),
          everyElement(TileLayerSplit.none),
        );
        // The tiles can stick out of the map too.
        final region = Rect.fromLTWH(
          0,
          0,
          whole.size.x,
          whole.size.y,
        ).inflate(200);
        await _settle();
        final expected = await renderMapRegionToPng(whole.tileMap, region);

        for (final chunkSize in [1, 2, 3]) {
          final split = await _load(map, chunkSize: chunkSize);
          await _settle();
          expect(
            await renderMapRegionToPng(split.tileMap, region),
            orderedEquals(expected),
            reason: 'runs of chunks of $chunkSize tiles',
          );
        }
      });

      test('renders what it renders unsplit, with a camera ($map)', () async {
        final whole = await _load(map);
        final size = whole.size;
        final viewSize = size / 3;
        for (final position in [
          size / 4,
          size / 2,
          Vector2(size.x * 0.8, size.y * 0.3),
          Vector2(size.x * 0.3, size.y * 0.9),
        ]) {
          final wholeGame = await _show(
            await _load(map),
            position,
            viewSize,
          );
          await _settle();
          final expected = await renderGameToPng(wholeGame);

          final split = await _load(map, chunkSize: 1);
          final splitGame = await _show(split, position, viewSize);
          await _settle();
          expect(
            await renderGameToPng(splitGame),
            orderedEquals(expected),
            reason: 'camera at $position',
          );
        }
      });
    }

    test('skips the runs that are out of view', () async {
      final component = await _load('test_isometric.tmx', chunkSize: 1);
      final size = component.size;
      final game = await _show(component, size / 4, size / 4);
      await renderGameToPng(game);

      final layer = _tileLayersOf(component).first;
      expect(layer.renderedChunkCount, greaterThan(0));
      expect(layer.renderedChunkCount, lessThan(layer.chunkCount));
    });

    test('keeps the run of a tile that was handed out rendered', () async {
      Future<int> renderedFarAway({required bool handOut}) async {
        final component = await _load('test_isometric.tmx', chunkSize: 1);
        if (handOut) {
          final stack = component.tileMap.tileStack(0, 0, all: true);
          expect(stack.length, greaterThan(0));
        }
        final game = await _show(
          component,
          Vector2.all(100000),
          Vector2.all(30),
        );
        await renderGameToPng(game);
        return _tileLayersOf(
          component,
        ).map((layer) => layer.renderedChunkCount).reduce((a, b) => a + b);
      }

      expect(await renderedFarAway(handOut: false), 0);
      expect(await renderedFarAway(handOut: true), greaterThan(0));
    });

    test('changing a tile rebuilds the runs', () async {
      final component = await _load('test_isometric.tmx', chunkSize: 1);
      final layer = _tileLayersOf(component).first;
      final before = layer.chunkCount;
      component.tileMap.setTileData(
        layerId: layer.layer.id!,
        x: 0,
        y: 0,
        gid: const Gid(0, Flips.defaults()),
      );
      expect(layer.split, TileLayerSplit.runs);
      expect(layer.chunkCount, inInclusiveRange(1, before));
    });
  });
}
