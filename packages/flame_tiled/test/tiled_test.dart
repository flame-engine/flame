import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_layer.dart';
import 'package:flame_tiled/src/tile_atlas.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_asset_bundle.dart';
import 'test_image_utils.dart';

void main() {
  /// This represents the byte count of one pixel.
  ///
  /// Usually, Color is represented as [Uint8List] and Uint8 has the ability to
  /// store 0 - 255(8 bit = 1 byte) per index. And it can be interpreted
  /// as [Color] by using 4 indexes of [Uint8List] into one.
  /// Examples:
  ///   RGBA [255, 0, 0 255] => red,
  ///   RGBA [255, 255, 0 255] => Yellow.
  const pixel = 4;
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(TiledAtlas.atlasMap.clear);
  group('TiledComponent', () {
    late TiledComponent tiled;
    setUp(() async {
      Flame.bundle = TestAssetBundle(
        imageNames: ['map-level1.png', 'image1.png'],
        stringNames: ['map.tmx', 'tiles_custom_path/map_custom_path.tmx'],
      );
      tiled = await TiledComponent.load('map.tmx', Vector2.all(16));
    });

    test('correct loads the file', () {
      expect(tiled.tileMap.renderableLayers.length, equals(3));
    });

    test('correct loads the file, with different prefix', () async {
      tiled = await TiledComponent.load(
        'map_custom_path.tmx',
        Vector2.all(16),
        prefix: 'assets/tiles/tiles_custom_path/',
      );

      expect(tiled.tileMap.renderableLayers.length, equals(3));
    });

    group('is positionable', () {
      test('size, width, and height are readable - not writable', () {
        expect(tiled.size, Vector2(512.0, 2048.0));
        expect(tiled.width, 512);
        expect(tiled.height, 2048);

        tiled.size = Vector2(256, 1024);
        expect(tiled.size, Vector2(512.0, 2048.0));
        tiled.width = 2;
        expect(tiled.size, Vector2(512.0, 2048.0));
        tiled.height = 2;
        expect(tiled.size, Vector2(512.0, 2048.0));
      });

      test('from constructor', () {
        final map = TiledComponent(
          tiled.tileMap,
          position: Vector2(10, 20),
          anchor: Anchor.bottomCenter,
          children: [tiled],
          angle: 1.4,
          priority: 2,
          scale: Vector2(1.5, 2.0),
        );

        expect(tiled.parent, map);
        expect(map.anchor, Anchor.bottomCenter);
        expect(map.angle, 1.4);
        expect(map.priority, 2);
        expect(map.position, Vector2(10, 20));
        expect(map.scale, Vector2(1.5, 2.0));
      });
    });
  });

  test('correctly loads external tileset', () async {
    // Flame.bundle is a global static. Updating these in tests can lead to
    // odd errors if you're trying to debug.
    Flame.bundle = TestAssetBundle(
      imageNames: ['map-level1.png', 'image1.png'],
      stringNames: ['map.tmx', 'tiles/external_tileset_1.tsx'],
    );

    final tsxProvider = await FlameTsxProvider.parse(
      'tiles/external_tileset_1.tsx',
      Flame.bundle,
    );

    expect(tsxProvider.getCachedSource() != null, true);
    final source = tsxProvider.getCachedSource()!;
    expect(source.getStringOrNull('name'), 'level1');
    expect(source.getSingleChildOrNull('image'), isNotNull);
    expect(
      source.getSingleChildOrNull('image')!.getStringOrNull('width'),
      '272',
    );

    expect(
      tsxProvider.filename == 'tiles/external_tileset_1.tsx',
      true,
    );
  });

  test('correctly loads external tileset with custom path', () async {
    // Flame.bundle is a global static. Updating these in tests can lead to
    // odd errors if you're trying to debug.
    Flame.bundle = TestAssetBundle(
      imageNames: ['map-level1.png', 'image1.png'],
      stringNames: [
        'map.tmx',
        'tiles_custom_path/external_tileset_custom_path.tsx',
      ],
    );

    // TestAssetBundle strips assets/tiles/ from the prefix.
    final tsxProvider = await FlameTsxProvider.parse(
      'external_tileset_custom_path.tsx',
      Flame.bundle,
      'assets/tiles/tiles_custom_path/',
    );

    expect(tsxProvider.getCachedSource() != null, true);
    final source = tsxProvider.getCachedSource()!;
    expect(source.getStringOrNull('name'), 'level1');
    expect(source.getSingleChildOrNull('image'), isNotNull);
    expect(
      source.getSingleChildOrNull('image')!.getStringOrNull('width'),
      '272',
    );

    expect(
      tsxProvider.filename == 'external_tileset_custom_path.tsx',
      true,
    );
  });

  group('Layered tiles render correctly with layered sprite batch', () {
    late Uint8List canvasPixelData;
    late RenderableTiledMap overlapMap;
    setUp(() async {
      final bundle = TestAssetBundle(
        imageNames: [
          'green_sprite.png',
          'red_sprite.png',
        ],
        stringNames: ['2_tiles-green_on_red.tmx'],
      );
      overlapMap = await RenderableTiledMap.fromFile(
        '2_tiles-green_on_red.tmx',
        Vector2.all(16),
        bundle: bundle,
        images: Images(bundle: bundle),
      );
      final canvasRecorder = PictureRecorder();
      final canvas = Canvas(canvasRecorder);
      overlapMap.render(canvas);
      final picture = canvasRecorder.endRecording();

      final image = await picture.toImageSafe(32, 16);
      final bytes = await image.toByteData();
      canvasPixelData = bytes!.buffer.asUint8List();
    });

    test(
      'Correctly loads batches list',
      () => expect(overlapMap.renderableLayers.length == 2, true),
    );

    test(
      'Canvas pixel dimensions match',
      () => expect(
        canvasPixelData.length == 16 * 32 * pixel,
        true,
      ),
    );

    test('Base test - right tile pixel is red', () {
      expect(
        canvasPixelData[16 * pixel] == 255 &&
            canvasPixelData[(16 * pixel) + 1] == 0 &&
            canvasPixelData[(16 * pixel) + 2] == 0 &&
            canvasPixelData[(16 * pixel) + 3] == 255,
        true,
      );
      final rightTilePixels = <int>[];
      for (var i = 16 * pixel; i < 16 * 32 * pixel; i += 32 * pixel) {
        rightTilePixels.addAll(canvasPixelData.getRange(i, i + (16 * pixel)));
      }

      var allRed = true;
      for (var i = 0; i < rightTilePixels.length; i += pixel) {
        allRed &= rightTilePixels[i] == 255 &&
            rightTilePixels[i + 1] == 0 &&
            rightTilePixels[i + 2] == 0 &&
            rightTilePixels[i + 3] == 255;
      }
      expect(allRed, true);
    });

    test('Left tile pixel is green', () {
      expect(
        canvasPixelData[15 * pixel] == 0 &&
            canvasPixelData[(15 * pixel) + 1] == 255 &&
            canvasPixelData[(15 * pixel) + 2] == 0 &&
            canvasPixelData[(15 * pixel) + 3] == 255,
        true,
      );

      final leftTilePixels = <int>[];
      for (var i = 0; i < 15 * 32 * pixel; i += 32 * pixel) {
        leftTilePixels.addAll(canvasPixelData.getRange(i, i + (16 * pixel)));
      }

      var allGreen = true;
      for (var i = 0; i < leftTilePixels.length; i += pixel) {
        allGreen &= leftTilePixels[i] == 0 &&
            leftTilePixels[i + 1] == 255 &&
            leftTilePixels[i + 2] == 0 &&
            leftTilePixels[i + 3] == 255;
      }
      expect(allGreen, true);
    });
  });

  group('Flipped and rotated tiles render correctly with sprite batch:', () {
    late Uint8List pixelsBeforeFlipApplied;
    late Uint8List pixelsAfterFlipApplied;
    late RenderableTiledMap overlapMap;

    Future<Uint8List> renderMap() async {
      final canvasRecorder = PictureRecorder();
      final canvas = Canvas(canvasRecorder);
      overlapMap.render(canvas);
      final picture = canvasRecorder.endRecording();

      final image = await picture.toImageSafe(64, 32);
      final bytes = await image.toByteData();
      return bytes!.buffer.asUint8List();
    }

    setUp(() async {
      final bundle = TestAssetBundle(
        imageNames: [
          '4_color_sprite.png',
        ],
        stringNames: ['8_tiles-flips.tmx'],
      );
      overlapMap = await RenderableTiledMap.fromFile(
        '8_tiles-flips.tmx',
        Vector2.all(16),
        bundle: bundle,
        images: Images(bundle: bundle),
      );

      pixelsBeforeFlipApplied = await renderMap();
      await Flame.images.ready();
      pixelsAfterFlipApplied = await renderMap();
    });

    test('[useAtlas = true] Green tile pixels are in correct spots', () {
      const oneColorRect = 8;
      final leftTilePixels = <int>[];
      for (var i = 65 * oneColorRect * pixel;
          i < ((64 * 23) + (oneColorRect * 3)) * pixel;
          i += 64 * pixel) {
        leftTilePixels
            .addAll(pixelsAfterFlipApplied.getRange(i, i + (16 * pixel)));
      }

      var allGreen = true;
      for (var i = 0; i < leftTilePixels.length; i += pixel) {
        allGreen &= leftTilePixels[i] == 0 &&
            leftTilePixels[i + 1] == 255 &&
            leftTilePixels[i + 2] == 0 &&
            leftTilePixels[i + 3] == 255;
      }
      expect(allGreen, true);

      final rightTilePixels = <int>[];
      for (var i = 69 * 8 * pixel;
          i < ((64 * 23) + (8 * 7)) * pixel;
          i += 64 * pixel) {
        rightTilePixels
            .addAll(pixelsAfterFlipApplied.getRange(i, i + (16 * pixel)));
      }

      for (var i = 0; i < rightTilePixels.length; i += pixel) {
        allGreen &= rightTilePixels[i] == 0 &&
            rightTilePixels[i + 1] == 255 &&
            rightTilePixels[i + 2] == 0 &&
            rightTilePixels[i + 3] == 255;
      }
      expect(allGreen, true);
    });

    test('[useAtlas = false] Green tile pixels are in correct spots', () {
      final leftTilePixels = <int>[];
      for (var i = 65 * 8 * pixel;
          i < ((64 * 23) + (8 * 3)) * pixel;
          i += 64 * pixel) {
        leftTilePixels
            .addAll(pixelsBeforeFlipApplied.getRange(i, i + (16 * pixel)));
      }

      var allGreen = true;
      for (var i = 0; i < leftTilePixels.length; i += pixel) {
        allGreen &= leftTilePixels[i] == 0 &&
            leftTilePixels[i + 1] == 255 &&
            leftTilePixels[i + 2] == 0 &&
            leftTilePixels[i + 3] == 255;
      }
      expect(allGreen, true);

      final rightTilePixels = <int>[];
      for (var i = 69 * 8 * pixel;
          i < ((64 * 23) + (8 * 7)) * pixel;
          i += 64 * pixel) {
        rightTilePixels
            .addAll(pixelsBeforeFlipApplied.getRange(i, i + (16 * pixel)));
      }

      for (var i = 0; i < rightTilePixels.length; i += pixel) {
        allGreen &= rightTilePixels[i] == 0 &&
            rightTilePixels[i + 1] == 255 &&
            rightTilePixels[i + 2] == 0 &&
            rightTilePixels[i + 3] == 255;
      }
      expect(allGreen, true);
    });
  });

  group('ignoring flip makes different texture and rendering result', () {
    Image? texture;
    Uint8List? rendered;

    Future<void> prepareForGolden({required bool ignoreFlip}) async {
      final bundle = TestAssetBundle(
        imageNames: [
          '4_color_sprite.png',
        ],
        stringNames: ['8_tiles-flips.tmx'],
      );
      final tiledComponent = TiledComponent(
        await RenderableTiledMap.fromFile(
          '8_tiles-flips.tmx',
          Vector2.all(16),
          ignoreFlip: ignoreFlip,
          bundle: bundle,
          images: Images(bundle: bundle),
        ),
      );

      await Flame.images.ready();

      texture = (tiledComponent.tileMap.renderableLayers[0] as FlameTileLayer)
          .tiledAtlas
          .batch
          ?.atlas;

      rendered = await renderMapToPng(tiledComponent);
    }

    test('flip works with [ignoreFlip = false]', () async {
      await prepareForGolden(ignoreFlip: false);
      expect(texture, matchesGoldenFile('goldens/texture_with_flip.png'));
      expect(rendered, matchesGoldenFile('goldens/rendered_with_flip.png'));
    });

    test('flip ignored with [ignoreFlip = true]', () async {
      await prepareForGolden(ignoreFlip: true);
      expect(
        texture,
        matchesGoldenFile('goldens/texture_with_flip_ignored.png'),
      );
      expect(
        rendered,
        matchesGoldenFile('goldens/rendered_with_flip_ignored.png'),
      );
    });
  });

  group('Test getLayer:', () {
    late RenderableTiledMap renderableTiledMap;
    setUp(() async {
      Flame.bundle = TestAssetBundle(
        imageNames: ['map-level1.png'],
        stringNames: ['layers_test.tmx'],
      );
      renderableTiledMap = await RenderableTiledMap.fromFile(
        'layers_test.tmx',
        Vector2.all(32),
        bundle: Flame.bundle,
      );
    });

    test('Get Tile Layer', () {
      expect(
        renderableTiledMap.getLayer<TileLayer>('MyTileLayer'),
        isNotNull,
      );
    });

    test('Get Object Layer', () {
      expect(
        renderableTiledMap.getLayer<ObjectGroup>('MyObjectLayer'),
        isNotNull,
      );
    });

    test('Get Image Layer', () {
      expect(
        renderableTiledMap.getLayer<ImageLayer>('MyImageLayer'),
        isNotNull,
      );
    });

    test('Get Group Layer', () {
      expect(
        renderableTiledMap.getLayer<Group>('MyGroupLayer'),
        isNotNull,
      );
    });

    test('Get no layer', () {
      expect(
        renderableTiledMap.getLayer<TileLayer>('Nonexistent layer'),
        isNull,
      );
    });
  });

  group('orthogonal with groups, offsets, opacity and parallax', () {
    late TiledComponent component;
    final mapSizePx = Vector2(32 * 16, 128 * 16);

    setUp(() async {
      Flame.bundle = TestAssetBundle(
        imageNames: [
          'image1.png',
          'map-level1.png',
        ],
        stringNames: ['map.tmx'],
      );
      component = await TiledComponent.load(
        'map.tmx',
        Vector2(16, 16),
        bundle: Flame.bundle,
      );

      // Need to initialize a game and call `onLoad` and `onGameResize` to
      // get the camera and canvas sizes all initialized
      final game = FlameGame();
      game.onGameResize(mapSizePx);
      final camera = game.camera;
      game.world.add(component);
      camera.viewfinder.position = Vector2(150, 20);
      camera.viewport.size = mapSizePx.clone();
      game.onGameResize(mapSizePx);
      component.onGameResize(mapSizePx);
      await component.onLoad();
      await game.ready();
    });

    test('component size', () {
      expect(component.tileMap.destTileSize, Vector2(16, 16));
      expect(component.size, mapSizePx);
    });

    test(
      'renders',
      () async {
        final pngData = await renderMapToPng(component);

        expect(pngData, matchesGoldenFile('goldens/orthogonal.png'));
      },
    );
  });

  group('isometric', () {
    late TiledComponent component;

    setUp(() async {
      final bundle = TestAssetBundle(
        imageNames: [
          'isometric_spritesheet.png',
        ],
        stringNames: ['test_isometric.tmx'],
      );
      component = await TiledComponent.load(
        'test_isometric.tmx',
        Vector2(256 / 4, 128 / 4),
        bundle: bundle,
        images: Images(bundle: bundle),
      );
    });

    test('component size', () {
      expect(component.tileMap.destTileSize, Vector2(64, 32));
      expect(component.size, Vector2(320, 160));
    });

    test('renders', () async {
      // Map size is now 320 wide, but it has 1 extra tile of height because
      // its actually double-height tiles.
      final pngData = await renderMapToPng(component);

      expect(pngData, matchesGoldenFile('goldens/isometric.png'));
    });
  });

  group('hexagonal', () {
    late TiledComponent component;

    Future<TiledComponent> setupMap(
      String tmxFile,
      String imageFile,
      Vector2 destTileSize,
    ) async {
      final bundle = TestAssetBundle(
        imageNames: [
          imageFile,
        ],
        stringNames: [tmxFile],
      );
      return component = await TiledComponent.load(
        tmxFile,
        destTileSize,
        bundle: bundle,
        images: Images(bundle: bundle),
      );
    }

    test('flat + even staggered', () async {
      await setupMap(
        'flat_hex_even.tmx',
        'Tileset_Hexagonal_FlatTop_60x39_60x60.png',
        Vector2(60, 39),
      );

      expect(component.size, Vector2(240, 214.5));

      final pngData = await renderMapToPng(component);

      expect(pngData, matchesGoldenFile('goldens/flat_hex_even.png'));
    });

    test('flat + odd staggered', () async {
      await setupMap(
        'flat_hex_odd.tmx',
        'Tileset_Hexagonal_FlatTop_60x39_60x60.png',
        Vector2(60, 39),
      );

      expect(component.size, Vector2(240, 214.5));

      final pngData = await renderMapToPng(component);

      expect(pngData, matchesGoldenFile('goldens/flat_hex_odd.png'));
    });

    test('pointy + even staggered', () async {
      await setupMap(
        'pointy_hex_even.tmx',
        'Tileset_Hexagonal_PointyTop_60x52_60x80.png',
        Vector2(60, 52),
      );

      expect(component.size, Vector2(330, 208));

      final pngData = await renderMapToPng(component);

      expect(pngData, matchesGoldenFile('goldens/pointy_hex_even.png'));
    });

    test('pointy + odd staggered', () async {
      await setupMap(
        'pointy_hex_odd.tmx',
        'Tileset_Hexagonal_PointyTop_60x52_60x80.png',
        Vector2(60, 52),
      );

      expect(component.size, Vector2(330, 208));

      final pngData = await renderMapToPng(component);

      expect(pngData, matchesGoldenFile('goldens/pointy_hex_odd.png'));
    });
  });

  group('isometric staggered', () {
    late TiledComponent component;

    Future<TiledComponent> setupMap(
      String tmxFile,
      String imageFile,
      Vector2 destTileSize,
    ) async {
      final bundle = TestAssetBundle(
        imageNames: [
          imageFile,
        ],
        stringNames: [tmxFile],
      );
      return component = await TiledComponent.load(
        tmxFile,
        destTileSize,
        bundle: bundle,
        images: Images(bundle: bundle),
      );
    }

    test('x + odd', () async {
      await setupMap(
        'iso_staggered_overlap_x_odd.tmx',
        'dirt_atlas.png',
        Vector2(128, 64),
      );

      expect(component.size, Vector2(320, 288));

      final pngData = await renderMapToPng(component);

      expect(
        pngData,
        matchesGoldenFile('goldens/iso_staggered_overlap_x_odd.png'),
      );
    });

    test('x + even + half sized', () async {
      await setupMap(
        'iso_staggered_overlap_x_even.tmx',
        'dirt_atlas.png',
        Vector2(128 / 2, 64 / 2),
      );

      expect(component.size, Vector2(320 / 2, 288 / 2));

      final pngData = await renderMapToPng(component);

      expect(
        pngData,
        matchesGoldenFile('goldens/iso_staggered_overlap_x_even.png'),
      );
    });

    test('y + odd + half', () async {
      await setupMap(
        'iso_staggered_overlap_y_odd.tmx',
        'dirt_atlas.png',
        Vector2(128 / 2, 64 / 2),
      );

      expect(component.size, Vector2(576 / 2, 160 / 2));

      final pngData = await renderMapToPng(component);

      expect(
        pngData,
        matchesGoldenFile('goldens/iso_staggered_overlap_y_odd.png'),
      );
    });

    test('y + even', () async {
      await setupMap(
        'iso_staggered_overlap_y_even.tmx',
        'dirt_atlas.png',
        Vector2(128, 64),
      );

      expect(component.size, Vector2(576, 160));

      final pngData = await renderMapToPng(component);

      expect(
        pngData,
        matchesGoldenFile('goldens/iso_staggered_overlap_y_even.png'),
      );
    });
  });

  group('shifted and scaled', () {
    late TiledComponent component;
    final size = Vector2(256, 128);

    Future<void> setupMap(
      Vector2 destTileSize,
    ) async {
      final bundle = TestAssetBundle(
        imageNames: [
          'isometric_spritesheet.png',
        ],
        stringNames: ['test_shifted.tmx'],
      );
      component = await TiledComponent.load(
        'test_shifted.tmx',
        destTileSize,
        bundle: bundle,
        images: Images(bundle: bundle),
      );
    }

    test('regular', () async {
      await setupMap(size);
      final pngData = await renderMapToPng(component);

      expect(
        pngData,
        matchesGoldenFile('goldens/shifted_scaled_regular.png'),
      );
    });

    test('smaller', () async {
      final smallSize = size / 3;
      await setupMap(smallSize);
      final pngData = await renderMapToPng(component);

      expect(
        pngData,
        matchesGoldenFile('goldens/shifted_scaled_smaller.png'),
      );
    });

    test('larger', () async {
      final largeSize = size * 2;
      await setupMap(largeSize);
      final pngData = await renderMapToPng(component);

      expect(
        pngData,
        matchesGoldenFile('goldens/shifted_scaled_larger.png'),
      );
    });
  });

  group('TileStack', () {
    late TiledComponent component;
    final size = Vector2(256 / 2, 128 / 2);

    setUp(() async {
      final bundle = TestAssetBundle(
        imageNames: [
          'isometric_spritesheet.png',
        ],
        stringNames: ['test_isometric.tmx'],
      );
      component = await TiledComponent.load(
        'test_isometric.tmx',
        size,
        bundle: bundle,
        images: Images(bundle: bundle),
      );
    });
    test('from all layers', () {
      var stack = component.tileMap.tileStack(0, 0, all: true);
      expect(stack.length, 2);

      stack = component.tileMap.tileStack(1, 0, all: true);
      expect(stack.length, 1);
    });

    test('from some layers', () {
      var stack = component.tileMap.tileStack(0, 0, named: {'empty'});
      expect(stack.length, 0);

      stack = component.tileMap.tileStack(0, 0, named: {'item'});
      expect(stack.length, 1);

      stack = component.tileMap.tileStack(0, 0, ids: {1});
      expect(stack.length, 1);

      stack = component.tileMap.tileStack(0, 0, ids: {1, 2});
      expect(stack.length, 2);
    });

    test('can be positioned together', () async {
      final stack = component.tileMap.tileStack(0, 0, all: true);
      stack.position = stack.position + Vector2.all(20);

      final pngData = await renderMapToPng(component);
      expect(
        pngData,
        matchesGoldenFile('goldens/tile_stack_all_move.png'),
      );
    });

    test('can be positioned singularly', () async {
      final stack = component.tileMap.tileStack(0, 0, named: {'item'});
      stack.position = stack.position + Vector2(-20, 20);

      final pngData = await renderMapToPng(component);
      expect(
        pngData,
        matchesGoldenFile('goldens/tile_stack_single_move.png'),
      );
    });
  });

  group('animated tiles', () {
    late TiledComponent component;
    late RenderableTiledMap map;
    final size = Vector2(16, 16);

    for (final mapType in [
      'orthogonal',
      'isometric',
      'hexagonal',
      'staggered',
    ]) {
      group(mapType, () {
        setUp(() async {
          final bundle = TestAssetBundle(
            imageNames: [
              '0x72_DungeonTilesetII_v1.4.png',
            ],
            stringNames: ['dungeon_animation_$mapType.tmx'],
          );
          component = await TiledComponent.load(
            'dungeon_animation_$mapType.tmx',
            size,
            bundle: bundle,
            images: Images(bundle: bundle),
          );
          map = component.tileMap;
        });

        test('handle single frame animations ($mapType)', () {
          expect(map.renderableLayers.first, isInstanceOf<FlameTileLayer>());
          final layer = map.renderableLayers.first as FlameTileLayer;
          expect(
            layer.animations,
            hasLength(1),
            reason: 'layer has only one animation',
          );
          expect(
            layer.animationFrames,
            hasLength(4),
            reason: 'layer only caches frames in use',
          );
          expect(layer.animations.first.frames.sources, hasLength(1));
        });

        test('handle single frame animations ($mapType)', () {
          expect(
            map.renderableLayers[1],
            isInstanceOf<FlameTileLayer>(),
          );
          final layer = map.renderableLayers[1] as FlameTileLayer;
          expect(
            layer.animations,
            hasLength(2),
            reason: 'two animations on this layer',
          );
          expect(
            layer.animationFrames,
            hasLength(4),
            reason: 'layer only caches frames in use',
          );

          final waterAnimation = layer.animations.first;
          final spikeAnimation = layer.animations.last;
          expect(waterAnimation.frames.durations, [.18, .17, .15]);
          expect(spikeAnimation.frames.durations, [.176, .176, .176, .176]);

          map.update(.177);
          expect(waterAnimation.frame, 0);
          expect(waterAnimation.frames.frameTime, .177);
          expect(
            waterAnimation.batchedSource.toRect(),
            waterAnimation.frames.sources[0],
          );

          expect(spikeAnimation.frame, 1);
          expect(spikeAnimation.frames.frameTime, moreOrLessEquals(.001));
          expect(
            spikeAnimation.batchedSource.toRect(),
            spikeAnimation.frames.sources[1],
          );

          map.update(.003);
          expect(waterAnimation.frame, 1);
          expect(waterAnimation.frames.frameTime, moreOrLessEquals(.0));
          expect(spikeAnimation.frame, 1);
          expect(spikeAnimation.frames.frameTime, moreOrLessEquals(0.004));

          map.update(0.17 + 0.15);
          expect(waterAnimation.frame, 0, reason: 'wraps around');
          expect(
            waterAnimation.batchedSource.toRect(),
            waterAnimation.frames.sources[0],
          );
        });

        /// This will not produce a pretty map for non-orthogonal, but that's
        /// OK, we're looking for parsing and handling of animations.
        test('renders ($mapType)', () async {
          var pngData = await renderMapToPng(component);
          await expectLater(
            pngData,
            matchesGoldenFile('goldens/dungeon_animation_${mapType}_0.png'),
          );

          component.update(0.18);
          pngData = await renderMapToPng(component);
          await expectLater(
            pngData,
            matchesGoldenFile('goldens/dungeon_animation_${mapType}_1.png'),
          );

          component.update(0.18);
          pngData = await renderMapToPng(component);
          await expectLater(
            pngData,
            matchesGoldenFile('goldens/dungeon_animation_${mapType}_2.png'),
          );

          component.update(0.18);
          pngData = await renderMapToPng(component);
          await expectLater(
            pngData,
            matchesGoldenFile('goldens/dungeon_animation_${mapType}_3.png'),
          );
        });
      });
    }
  });

  group('oversized tiles', () {
    late TiledComponent component;
    final size = Vector2(16, 16);

    for (final mapType in [
      'orthogonal',
      'isometric',
      'hexagonal',
      'staggered',
    ]) {
      group(mapType, () {
        setUp(() async {
          final bundle = TestAssetBundle(
            imageNames: [
              '0x72_DungeonTilesetII_v1.4.png',
            ],
            stringNames: ['oversized_tiles_$mapType.tmx'],
          );
          component = await TiledComponent.load(
            'oversized_tiles_$mapType.tmx',
            size,
            bundle: bundle,
            images: Images(bundle: bundle),
          );
        });

        test('renders ($mapType)', () async {
          final pngData = await renderMapToPng(component);
          await expectLater(
            pngData,
            matchesGoldenFile('goldens/oversized_tiles_$mapType.png'),
          );
        });
      });
    }
  });
}
