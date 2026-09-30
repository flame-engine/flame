import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/renderable_layers/group_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_layer.dart';
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
      tiled = await TiledComponent.load(
        'assets/tiles/map.tmx',
        Vector2.all(16),
        key: ComponentKey.named('test'),
      );
    });

    test('correct loads the file', () {
      expect(tiled.tileMap.renderableLayers.length, equals(4));
    });

    test('component atlases returns the loaded atlases', () {
      final atlases = tiled.atlases();
      expect(atlases, hasLength(1));
      expect(atlases.first.$1, equals('assets/images/map-level1.png'));
    });

    test('correct loads the file, from a nested directory', () async {
      tiled = await TiledComponent.load(
        'assets/tiles/tiles_custom_path/map_custom_path.tmx',
        Vector2.all(16),
      );

      expect(tiled.tileMap.renderableLayers.length, equals(3));
    });

    test('assigns key', () async {
      expect(tiled.key, equals(ComponentKey.named('test')));
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

      test('from constructor', () async {
        final tileMap = await RenderableTiledMap.fromFile(
          'assets/tiles/map.tmx',
          Vector2.all(16),
        );
        final map = TiledComponent(
          tileMap,
          position: Vector2(10, 20),
          anchor: Anchor.bottomCenter,
          children: [tiled],
          angle: 1.4,
          priority: 2,
          scale: Vector2(1.5, 2.0),
        );

        expect(tiled.parent, map);
        expect(tileMap.parent, map);
        expect(map.anchor, Anchor.bottomCenter);
        expect(map.angle, 1.4);
        expect(map.priority, 2);
        expect(map.position, Vector2(10, 20));
        expect(map.scale, Vector2(1.5, 2.0));
      });

      test('a map can only belong to one component', () {
        expect(
          () => TiledComponent(tiled.tileMap),
          failsAssert(
            'A RenderableTiledMap can only belong to one TiledComponent',
          ),
        );
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
        'assets/tiles/2_tiles-green_on_red.tmx',
        Vector2.all(16),
        bundle: bundle,
        images: Images(bundle: bundle),
      );
      final canvasRecorder = PictureRecorder();
      final canvas = Canvas(canvasRecorder);
      overlapMap.renderTree(canvas);
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
        allRed &=
            rightTilePixels[i] == 255 &&
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
        allGreen &=
            leftTilePixels[i] == 0 &&
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
      overlapMap.renderTree(canvas);
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
        'assets/tiles/8_tiles-flips.tmx',
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
      for (
        var i = 65 * oneColorRect * pixel;
        i < ((64 * 23) + (oneColorRect * 3)) * pixel;
        i += 64 * pixel
      ) {
        leftTilePixels.addAll(
          pixelsAfterFlipApplied.getRange(i, i + (16 * pixel)),
        );
      }

      var allGreen = true;
      for (var i = 0; i < leftTilePixels.length; i += pixel) {
        allGreen &=
            leftTilePixels[i] == 0 &&
            leftTilePixels[i + 1] == 255 &&
            leftTilePixels[i + 2] == 0 &&
            leftTilePixels[i + 3] == 255;
      }
      expect(allGreen, true);

      final rightTilePixels = <int>[];
      for (
        var i = 69 * 8 * pixel;
        i < ((64 * 23) + (8 * 7)) * pixel;
        i += 64 * pixel
      ) {
        rightTilePixels.addAll(
          pixelsAfterFlipApplied.getRange(i, i + (16 * pixel)),
        );
      }

      for (var i = 0; i < rightTilePixels.length; i += pixel) {
        allGreen &=
            rightTilePixels[i] == 0 &&
            rightTilePixels[i + 1] == 255 &&
            rightTilePixels[i + 2] == 0 &&
            rightTilePixels[i + 3] == 255;
      }
      expect(allGreen, true);
    });

    test('[useAtlas = false] Green tile pixels are in correct spots', () {
      final leftTilePixels = <int>[];
      for (
        var i = 65 * 8 * pixel;
        i < ((64 * 23) + (8 * 3)) * pixel;
        i += 64 * pixel
      ) {
        leftTilePixels.addAll(
          pixelsBeforeFlipApplied.getRange(i, i + (16 * pixel)),
        );
      }

      var allGreen = true;
      for (var i = 0; i < leftTilePixels.length; i += pixel) {
        allGreen &=
            leftTilePixels[i] == 0 &&
            leftTilePixels[i + 1] == 255 &&
            leftTilePixels[i + 2] == 0 &&
            leftTilePixels[i + 3] == 255;
      }
      expect(allGreen, true);

      final rightTilePixels = <int>[];
      for (
        var i = 69 * 8 * pixel;
        i < ((64 * 23) + (8 * 7)) * pixel;
        i += 64 * pixel
      ) {
        rightTilePixels.addAll(
          pixelsBeforeFlipApplied.getRange(i, i + (16 * pixel)),
        );
      }

      for (var i = 0; i < rightTilePixels.length; i += pixel) {
        allGreen &=
            rightTilePixels[i] == 0 &&
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
          'assets/tiles/8_tiles-flips.tmx',
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
        'assets/tiles/layers_test.tmx',
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

      // Need to initialize a game and call `onGameResize` to get the camera
      // and canvas sizes all initialized
      final game = FlameGame();
      game.onGameResize(mapSizePx);
      final camera = game.camera;
      component = await TiledComponent.load(
        'assets/tiles/map.tmx',
        Vector2(16, 16),
        bundle: Flame.bundle,
        camera: camera,
      );
      game.world.add(component);
      camera.viewfinder.position = Vector2(150, 20);
      camera.viewport.size = mapSizePx.clone();
      game.onGameResize(mapSizePx);
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

    test('layers are positioned for the parallax factor and offset', () async {
      await renderMapToPng(component);
      final layers = component.tileMap.renderableLayers;

      // The view is centered on the camera position (150, 20), so a layer with
      // a parallax factor of 0.4 is displaced by 0.6 times that.
      final ground = layers[0];
      expect(ground.position, Vector2.zero());
      final background = layers[1] as GroupLayer;
      expect(background.position, Vector2(-50 + 90, -100 + 12));
      final skyTiles = background.children.first as FlameTileLayer;
      expect(skyTiles.parallaxX, 0.4);
      expect(skyTiles.position, Vector2(100, 100));
      expect(skyTiles.absolutePosition, Vector2(140, 12));
    });
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
        'assets/tiles/test_isometric.tmx',
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

  group('tile offset', () {
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

    test('tile offset hexagonal', () async {
      await setupMap(
        // flame tiled currently does not support hexagon side length property,
        // to use export from Tiled, tweak that value
        'test_tile_offset_hexagonal.tmx',
        '4_color_sprite.png',
        Vector2(16, 16),
      );

      expect(component.size, Vector2(40, 28));

      final pngData = await renderMapToPng(component);

      expect(
        pngData,
        matchesGoldenFile('goldens/test_tile_offset_hexagonal.png'),
      );
    });

    test('tile offset isometric', () async {
      await setupMap(
        'test_tile_offset_isometric.tmx',
        '4_color_sprite.png',
        Vector2(16, 16),
      );

      expect(component.size, Vector2(32, 32));

      final pngData = await renderMapToPng(component);

      expect(
        pngData,
        matchesGoldenFile('goldens/test_tile_offset_isometric.png'),
      );
    });

    test('tile offset orthogonal', () async {
      await setupMap(
        'test_tile_offset_orthogonal.tmx',
        '4_color_sprite.png',
        Vector2(16, 16),
      );

      expect(component.size, Vector2(32, 32));

      final pngData = await renderMapToPng(component);

      expect(
        pngData,
        matchesGoldenFile('goldens/test_tile_offset_orthogonal.png'),
      );
    });

    test('tile offset staggered', () async {
      await setupMap(
        'test_tile_offset_staggered.tmx',
        '4_color_sprite.png',
        Vector2(16, 16),
      );

      expect(component.size, Vector2(40, 24));

      final pngData = await renderMapToPng(component);

      expect(
        pngData,
        matchesGoldenFile('goldens/test_tile_offset_staggered.png'),
      );
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
        'assets/tiles/test_shifted.tmx',
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
        'assets/tiles/test_isometric.tmx',
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
            'assets/tiles/dungeon_animation_$mapType.tmx',
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
          expect(waterAnimation.frames.durations, [0.18, 0.17, 0.15]);
          expect(spikeAnimation.frames.durations, [0.176, 0.176, 0.176, 0.176]);

          map.updateTree(0.177);
          expect(waterAnimation.frame, 0);
          expect(waterAnimation.frames.frameTime, 0.177);
          expect(
            waterAnimation.batchedSource.toRect(),
            waterAnimation.frames.sources[0],
          );

          expect(spikeAnimation.frame, 1);
          expect(spikeAnimation.frames.frameTime, moreOrLessEquals(0.001));
          expect(
            spikeAnimation.batchedSource.toRect(),
            spikeAnimation.frames.sources[1],
          );

          map.updateTree(0.003);
          expect(waterAnimation.frame, 1);
          expect(waterAnimation.frames.frameTime, moreOrLessEquals(0.0));
          expect(spikeAnimation.frame, 1);
          expect(spikeAnimation.frames.frameTime, moreOrLessEquals(0.004));

          map.updateTree(0.17 + 0.15);
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

          component.updateTree(0.18);
          pngData = await renderMapToPng(component);
          await expectLater(
            pngData,
            matchesGoldenFile('goldens/dungeon_animation_${mapType}_1.png'),
          );

          component.updateTree(0.18);
          pngData = await renderMapToPng(component);
          await expectLater(
            pngData,
            matchesGoldenFile('goldens/dungeon_animation_${mapType}_2.png'),
          );

          component.updateTree(0.18);
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
            'assets/tiles/oversized_tiles_$mapType.tmx',
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

  group('RenderableTiledMap.TileData', () {
    late RenderableTiledMap renderableTiledMap;

    setUp(() async {
      final bundle = TestAssetBundle(
        imageNames: ['4_color_sprite.png'],
        stringNames: ['deleted_layer_map.tmx'],
      );
      renderableTiledMap = await RenderableTiledMap.fromFile(
        'assets/tiles/deleted_layer_map.tmx',
        Vector2.all(16),
        bundle: bundle,
        images: Images(bundle: bundle),
      );
    });

    test('same TileData is found by layerId and layerIndex', () {
      final tileData1 = renderableTiledMap.getTileData(layerId: 6, x: 5, y: 3);
      final tileData2 = renderableTiledMap.getTileDataByLayerIndex(
        layerIndex: 4,
        x: 5,
        y: 3,
      );
      expect(tileData1, isNotNull);
      expect(tileData2, isNotNull);
      expect(tileData1, equals(tileData2));
    });

    test('returns null for non-existent layer', () {
      expect(renderableTiledMap.getTileData(layerId: 3, x: 1, y: 1), isNull);
      expect(renderableTiledMap.getTileData(layerId: 5, x: 1, y: 1), isNull);
    });
  });

  group('RenderableTiledMap.LayerOpacity', () {
    late RenderableTiledMap renderableTiledMap;

    setUp(() async {
      Flame.bundle = TestAssetBundle(
        imageNames: ['map-level1.png'],
        stringNames: ['layers_test.tmx'],
      );
      renderableTiledMap = await RenderableTiledMap.fromFile(
        'assets/tiles/layers_test.tmx',
        Vector2.all(32),
        bundle: Flame.bundle,
      );
    });

    test('getLayerOpacity returns 1.0 by default', () {
      expect(renderableTiledMap.getLayerOpacity(0), equals(1.0));
    });

    test('setLayerOpacity changes the layer opacity', () {
      renderableTiledMap.setLayerOpacity(0, opacity: 0.5);
      expect(renderableTiledMap.getLayerOpacity(0), equals(0.5));
    });

    test('setLayerOpacity sets opacity to 0', () {
      renderableTiledMap.setLayerOpacity(0, opacity: 0.0);
      expect(renderableTiledMap.getLayerOpacity(0), equals(0.0));
    });

    test('setLayerOpacity sets opacity to 1', () {
      renderableTiledMap.setLayerOpacity(0, opacity: 0.25);
      renderableTiledMap.setLayerOpacity(0, opacity: 1.0);
      expect(renderableTiledMap.getLayerOpacity(0), equals(1.0));
    });

    test('setLayerOpacity asserts on out-of-range value', () {
      expect(
        () => renderableTiledMap.setLayerOpacity(0, opacity: 1.5),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => renderableTiledMap.setLayerOpacity(0, opacity: -0.1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('layers are components', () {
    late RenderableTiledMap overlapMap;

    Future<Uint8List> renderMap() async {
      final canvasRecorder = PictureRecorder();
      final canvas = Canvas(canvasRecorder);
      overlapMap.renderTree(canvas);
      final picture = canvasRecorder.endRecording();

      final image = await picture.toImageSafe(32, 16);
      final bytes = await image.toByteData();
      return bytes!.buffer.asUint8List();
    }

    List<int> pixelAt(Uint8List pixels, int x, int y) {
      final index = (y * 32 + x) * pixel;
      return pixels.sublist(index, index + pixel);
    }

    setUp(() async {
      final bundle = TestAssetBundle(
        imageNames: [
          'green_sprite.png',
          'red_sprite.png',
        ],
        stringNames: ['2_tiles-green_on_red.tmx'],
      );
      overlapMap = await RenderableTiledMap.fromFile(
        'assets/tiles/2_tiles-green_on_red.tmx',
        Vector2.all(16),
        bundle: bundle,
        images: Images(bundle: bundle),
      );
    });

    test('the layers are the children of the map, in map order', () {
      expect(overlapMap.children.toList(), overlapMap.renderableLayers);
      expect(
        overlapMap.renderableLayers.map((layer) => layer.layer.name),
        ['red_tile-base', 'green_tile-top'],
      );
    });

    test('getRenderableLayer finds top level layers', () {
      final layer = overlapMap.getRenderableLayer('green_tile-top');
      expect(layer, isA<FlameTileLayer>());
      expect(layer!.layer.name, 'green_tile-top');
      expect(overlapMap.getRenderableLayer('Nonexistent layer'), isNull);
    });

    test('components added to a layer render between the layers', () async {
      final blue = RectangleComponent(
        size: Vector2(32, 16),
        paint: Paint()..color = const Color(0xff0000ff),
      );
      overlapMap.getRenderableLayer('red_tile-base')!.add(blue);

      final pixels = await renderMap();
      // The green tile is on the layer above the rectangle.
      expect(pixelAt(pixels, 8, 8), [0, 255, 0, 255]);
      // The red tile is on the layer below the rectangle.
      expect(pixelAt(pixels, 24, 8), [0, 0, 255, 255]);
    });

    test('children of the TiledComponent render on top of the map', () async {
      final blue = RectangleComponent(
        size: Vector2(32, 16),
        paint: Paint()..color = const Color(0xff0000ff),
      );
      final component = TiledComponent(overlapMap, children: [blue]);
      final canvasRecorder = PictureRecorder();
      component.renderTree(Canvas(canvasRecorder));
      final picture = canvasRecorder.endRecording();
      final image = await picture.toImageSafe(32, 16);
      final pixels = (await image.toByteData())!.buffer.asUint8List();

      expect(pixelAt(pixels, 8, 8), [0, 0, 255, 255]);
      expect(pixelAt(pixels, 24, 8), [0, 0, 255, 255]);
    });

    test('components added to a layer follow the offset of the layer', () {
      final layer = overlapMap.getRenderableLayer('green_tile-top')!;
      final marker = PositionComponent(position: Vector2(4, 2));
      layer.add(marker);
      layer
        ..offsetX = 10
        ..offsetY = 20;

      final canvasRecorder = PictureRecorder();
      overlapMap.renderTree(Canvas(canvasRecorder));

      expect(layer.position, Vector2(10, 20));
      expect(marker.absolutePosition, Vector2(14, 22));
    });

    test('invisible layers are kept but not rendered', () async {
      overlapMap.setLayerVisibility(1, visible: false);
      expect(overlapMap.renderableLayers, hasLength(2));
      expect(overlapMap.renderableLayers[1].visible, isFalse);

      var pixels = await renderMap();
      expect(pixelAt(pixels, 8, 8), [255, 0, 0, 255]);

      overlapMap.setLayerVisibility(1, visible: true);
      pixels = await renderMap();
      expect(pixelAt(pixels, 8, 8), [0, 255, 0, 255]);
    });
  });

  group('parallax', () {
    late FlameGame game;
    late TiledComponent component;
    final screenSize = Vector2(320, 240);

    setUp(() async {
      final bundle = TestAssetBundle(
        imageNames: [
          'map-level1.png',
          'images/diamond.png',
          'images/box2.png',
        ],
        stringNames: ['parallax_test.tmx'],
      );
      component = await TiledComponent.load(
        'assets/tiles/parallax_test.tmx',
        Vector2.all(16),
        bundle: bundle,
        images: Images(bundle: bundle),
      );

      game = await initializeFlameGame();
      game.onGameResize(screenSize);
      game.world.add(component);
      await game.ready();
    });

    tearDown(() => game.onRemove());

    test('getRenderableLayer finds layers nested in groups', () {
      final boxes = component.tileMap.getRenderableLayer('Boxes')!;
      expect(boxes.layer.name, 'Boxes');
      expect(boxes.parentLayer!.layer.name, 'Group 2');
      expect(boxes.parentLayer!.parentLayer!.layer.name, 'Group1');
      expect(boxes.parallaxX, closeTo(2 * 1.1, 1e-4));
      expect(boxes.parallaxY, closeTo(3.8 * 1.1, 1e-4));
    });

    test('layers are displaced by the view center of the camera', () async {
      game.camera.viewfinder.position = Vector2(400, 160);
      await renderGameToPng(game);

      final map = component.tileMap;
      expect(map.renderableLayers[0].position, Vector2.zero());

      // Middle: parallax factor 1.5, displaced by 400 * (1 - 1.5) = -200.
      final middle = map.getRenderableLayer('Middle')!;
      expect(middle.position, Vector2(-200, 0));

      // Foreground: parallax 1.2 on both axes.
      final foreground = map.getRenderableLayer('Foreground')!;
      expect(foreground.position.x, closeTo(400 * -0.2, 1e-4));
      expect(foreground.position.y, closeTo(160 * -0.2, 1e-4));

      // Group1: offset (-12, 6), parallax (2, 3.8).
      final group = map.getRenderableLayer('Group1')!;
      expect(group.position.x, closeTo(-12 + 400 * -1, 1e-4));
      expect(group.position.y, closeTo(6 + 160 * -2.8, 1e-4));

      // Boxes: offset (1, 10), parallax (1.1, 1.1) inside Group 2 inside
      // Group1. The total displacement follows the total parallax factor.
      final boxes = map.getRenderableLayer('Boxes')!;
      expect(boxes.position.x, closeTo(1 + 400 * 2 * -0.1, 1e-4));
      expect(boxes.position.y, closeTo(10 + 160 * 3.8 * -0.1, 1e-4));
      expect(
        boxes.absolutePosition.x,
        closeTo(-12 + 1 + 400 * (1 - 2 * 1.1), 1e-4),
      );
      expect(
        boxes.absolutePosition.y,
        closeTo(6 + 10 + 160 * (1 - 3.8 * 1.1), 1e-4),
      );
    });

    test('a map outside of the world uses the camera of the game', () async {
      component.removeFromParent();
      game.add(component);
      await game.ready();
      game.camera.viewfinder.position = Vector2(400, 160);
      await renderGameToPng(game);

      final middle = component.tileMap.getRenderableLayer('Middle')!;
      expect(middle.position, Vector2(-200, 0));
    });

    test('a scaled map is displaced in its own coordinate space', () async {
      component.scale = Vector2.all(2);
      game.camera.viewfinder.position = Vector2(400, 160);
      await renderGameToPng(game);

      // The view center is at (200, 80) in the coordinate space of the map.
      final middle = component.tileMap.getRenderableLayer('Middle')!;
      expect(middle.position, Vector2(-100, 0));
    });

    test('renders through the camera at the parallax origin', () async {
      game.camera.viewfinder.position = Vector2.zero();
      final pngData = await renderGameToPng(game);
      expect(
        pngData,
        matchesGoldenFile('goldens/parallax_camera_origin.png'),
      );
    });

    test('renders through the camera away from the origin', () async {
      game.camera.viewfinder.position = Vector2(400, 160);
      final pngData = await renderGameToPng(game);
      expect(
        pngData,
        matchesGoldenFile('goldens/parallax_camera_offset.png'),
      );
    });

    test('repeating image layers cover the view far from the origin', () async {
      component.tileMap.setLayerVisibility(2, visible: true);
      game.camera.viewfinder.position = Vector2(2000, 1500);
      final pngData = await renderGameToPng(game);
      expect(
        pngData,
        matchesGoldenFile('goldens/parallax_camera_repeat.png'),
      );
    });
  });

  group('RenderableTiledMap.LayerOpacity nested groups', () {
    // map.tmx layer structure (renderableLayers indices):
    //   0: FlameTileLayer  "Ground"          (opacity 1.0)
    //   1: GroupLayer      "Background"      (opacity 0.8)
    //      └─ FlameTileLayer "Sky tiles"     (own opacity 0.9, effective 0.72)
    //   2: FlameImageLayer "Image Layer 2"   (opacity 1.0)
    //   3: FlameImageLayer "Sky artifact"    (opacity 0.2)
    late RenderableTiledMap renderableTiledMap;

    setUp(() async {
      Flame.bundle = TestAssetBundle(
        imageNames: ['image1.png', 'map-level1.png'],
        stringNames: ['map.tmx'],
      );
      renderableTiledMap = await RenderableTiledMap.fromFile(
        'assets/tiles/map.tmx',
        Vector2.all(16),
        bundle: Flame.bundle,
      );
    });

    test('child effective opacity is parent * own', () {
      // GroupLayer opacity=0.8, child TileLayer own opacity=0.9 → 0.72
      final group = renderableTiledMap.renderableLayers[1] as GroupLayer;
      final child = group.children.first as FlameTileLayer;
      expect(child.opacity, closeTo(0.72, 1e-6));
    });

    test('setting GroupLayer opacity updates child effective opacity', () {
      // Change group from 0.8→0.5; child own opacity stays 0.9→effective 0.45
      renderableTiledMap.setLayerOpacity(1, opacity: 0.5);
      final group = renderableTiledMap.renderableLayers[1] as GroupLayer;
      expect(group.opacity, equals(0.5));
      final child = group.children.first as FlameTileLayer;
      expect(child.opacity, closeTo(0.45, 1e-6));
    });

    test('setting GroupLayer opacity to 0 makes child fully transparent', () {
      renderableTiledMap.setLayerOpacity(1, opacity: 0.0);
      final group = renderableTiledMap.renderableLayers[1] as GroupLayer;
      final child = group.children.first as FlameTileLayer;
      expect(child.opacity, equals(0.0));
    });

    test('sibling layers are not affected by group opacity change', () {
      renderableTiledMap.setLayerOpacity(1, opacity: 0.1);
      // "Ground" at index 0 has no parent, so remains 1.0
      expect(renderableTiledMap.getLayerOpacity(0), equals(1.0));
      // "Sky artifact" at index 3 is independent
      expect(renderableTiledMap.getLayerOpacity(3), equals(0.2));
    });
  });

  group('infinite maps', () {
    test('empty infinite map loads without tiles', () async {
      final bundle = TestAssetBundle(
        imageNames: const [],
        stringNames: ['empty-infinite-map.tmx'],
      );
      final component = await TiledComponent.load(
        'assets/tiles/empty-infinite-map.tmx',
        Vector2.all(16),
        bundle: bundle,
        images: Images(bundle: bundle),
      );

      expect(component.tileMap.map.infinite, isTrue);
      expect(component.size, Vector2(120 * 16, 68 * 16));
      expect(
        component.tileMap.getTileData(layerId: 1, x: 0, y: 0),
        isNull,
      );
    });

    test('loads chunks and reads Tiled world coordinates', () async {
      final bundle = TestAssetBundle(
        imageNames: ['0x72_DungeonTilesetII_v1.4.png'],
        stringNames: ['infinite-map.tmx'],
      );
      final map = await RenderableTiledMap.fromFile(
        'assets/tiles/infinite-map.tmx',
        Vector2.all(16),
        bundle: bundle,
        images: Images(bundle: bundle),
      );

      expect(map.map.infinite, isTrue);

      final floorTile = map.getTileData(layerId: 2, x: -16, y: -7);
      expect(floorTile, isNotNull);
      expect(floorTile!.tile, 132);

      expect(map.getTileData(layerId: 2, x: 1000, y: 1000), isNull);

      map.setTileData(
        layerId: 2,
        x: -16,
        y: -7,
        gid: const Gid(1, Flips.defaults()),
      );
      expect(map.getTileData(layerId: 2, x: -16, y: -7)!.tile, 1);

      final stack = map.tileStack(-16, -7, all: true);
      expect(stack.length, greaterThan(0));
      // Tiles at negative indices are placed at negative world positions,
      // like in the Tiled editor.
      expect(stack.position, Vector2((-16 + 0.5) * 16, (-7 + 0.5) * 16));
    });

    test('TiledComponent size uses map width and height', () async {
      final bundle = TestAssetBundle(
        imageNames: ['0x72_DungeonTilesetII_v1.4.png'],
        stringNames: ['infinite-map.tmx'],
      );
      final component = await TiledComponent.load(
        'assets/tiles/infinite-map.tmx',
        Vector2.all(16),
        bundle: bundle,
        images: Images(bundle: bundle),
      );

      expect(component.size, Vector2(120 * 16, 68 * 16));
    });

    test('renders all chunks', () async {
      final bundle = TestAssetBundle(
        imageNames: ['0x72_DungeonTilesetII_v1.4.png'],
        stringNames: ['infinite-map.tmx'],
      );
      final map = await RenderableTiledMap.fromFile(
        'assets/tiles/infinite-map.tmx',
        Vector2.all(16),
        bundle: bundle,
        images: Images(bundle: bundle),
      );

      // The chunks cover tiles (-32, -16) to (16, 16).
      final pngData = await renderMapRegionToPng(
        map,
        const Rect.fromLTWH(-32 * 16, -16 * 16, 48 * 16, 32 * 16),
      );
      await expectLater(
        pngData,
        matchesGoldenFile('goldens/infinite_map.png'),
      );
    });

    // The room straddles the border between two chunks. Its door is a 32x32
    // tile standing on the floor in front of the top wall, so it overlaps wall
    // tiles of both chunks. Painting chunk by chunk instead of row by row
    // would draw the wall of the right chunk over the door.
    test('paints oversized tiles across chunks in row order', () async {
      final bundle = TestAssetBundle(
        imageNames: ['0x72_DungeonTilesetII_v1.4.png'],
        stringNames: ['infinite_oversized_tiles_orthogonal.tmx'],
      );
      final map = await RenderableTiledMap.fromFile(
        'assets/tiles/infinite_oversized_tiles_orthogonal.tmx',
        Vector2.all(16),
        bundle: bundle,
        images: Images(bundle: bundle),
      );

      // The room covers tiles (-8, 0) to (7, 10).
      final pngData = await renderMapRegionToPng(
        map,
        const Rect.fromLTWH(-8 * 16, 0, 16 * 16, 11 * 16),
      );
      await expectLater(
        pngData,
        matchesGoldenFile('goldens/infinite_oversized_tiles_orthogonal.png'),
      );
    });

    test('renders isometric chunks around the origin', () async {
      final bundle = TestAssetBundle(
        imageNames: ['isometric_spritesheet.png'],
        stringNames: ['infinite_oversized_tiles_isometric.tmx'],
      );
      final map = await RenderableTiledMap.fromFile(
        'assets/tiles/infinite_oversized_tiles_isometric.tmx',
        Vector2(64, 32),
        bundle: bundle,
        images: Images(bundle: bundle),
      );

      final pngData = await renderMapRegionToPng(
        map,
        const Rect.fromLTWH(0, -144, 384, 240),
      );
      await expectLater(
        pngData,
        matchesGoldenFile('goldens/infinite_oversized_tiles_isometric.png'),
      );
    });
  });
}
