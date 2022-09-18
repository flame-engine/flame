import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layer.dart'
    as renderable;

import 'package:flutter/services.dart' show CachingAssetBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:tiled/tiled.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TiledComponent', () {
    late TiledComponent tiled;
    setUp(() async {
      Flame.bundle = TestAssetBundle(
        imageNames: ['map-level1.png', 'image1.png'],
        mapPath: 'test/assets/map.tmx',
      );
      tiled = await TiledComponent.load('x', Vector2.all(16));
    });

    test('correct loads the file', () async {
      expect(tiled.tileMap.renderableLayers.length, equals(3));
    });

    group('is positionable', () {
      test('size, width, and height are readable - not writable', () async {
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
    final tsxProvider = await FlameTsxProvider.parse('external_tileset_1.tsx');

    expect(tsxProvider.getCachedSource() != null, true);
    expect(
      tsxProvider
              .getCachedSource()!
              .getSingleChild('tileset')
              .getString('name') ==
          'level1',
      true,
    );

    expect(
      tsxProvider.filename == 'external_tileset_1.tsx',
      true,
    );
  });

  group('Layered tiles render correctly with layered sprite batch', () {
    late Uint8List canvasPixelData;
    late RenderableTiledMap overlapMap;
    setUp(() async {
      Flame.bundle = TestAssetBundle(
        imageNames: [
          'green_sprite.png',
          'red_sprite.png',
        ],
        mapPath: 'test/assets/2_tiles-green_on_red.tmx',
      );
      overlapMap = await RenderableTiledMap.fromFile(
        '2_tiles-green_on_red.tmx',
        Vector2.all(16),
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
        canvasPixelData.length == 16 * 32 * 4,
        true,
      ),
    );

    test('Base test - right tile pixel is red', () {
      expect(
        canvasPixelData[16 * 4] == 255 &&
            canvasPixelData[(16 * 4) + 1] == 0 &&
            canvasPixelData[(16 * 4) + 2] == 0 &&
            canvasPixelData[(16 * 4) + 3] == 255,
        true,
      );
      final rightTilePixels = <int>[];
      for (var i = 16 * 4; i < 16 * 32 * 4; i += 32 * 4) {
        rightTilePixels.addAll(canvasPixelData.getRange(i, i + (16 * 4)));
      }

      var allRed = true;
      for (var i = 0; i < rightTilePixels.length; i += 4) {
        allRed &= rightTilePixels[i] == 255 &&
            rightTilePixels[i + 1] == 0 &&
            rightTilePixels[i + 2] == 0 &&
            rightTilePixels[i + 3] == 255;
      }
      expect(allRed, true);
    });

    test('Left tile pixel is green', () {
      expect(
        canvasPixelData[15 * 4] == 0 &&
            canvasPixelData[(15 * 4) + 1] == 255 &&
            canvasPixelData[(15 * 4) + 2] == 0 &&
            canvasPixelData[(15 * 4) + 3] == 255,
        true,
      );

      final leftTilePixels = <int>[];
      for (var i = 0; i < 15 * 32 * 4; i += 32 * 4) {
        leftTilePixels.addAll(canvasPixelData.getRange(i, i + (16 * 4)));
      }

      var allGreen = true;
      for (var i = 0; i < leftTilePixels.length; i += 4) {
        allGreen &= leftTilePixels[i] == 0 &&
            leftTilePixels[i + 1] == 255 &&
            leftTilePixels[i + 2] == 0 &&
            leftTilePixels[i + 3] == 255;
      }
      expect(allGreen, true);
    });
  });

  group('Flipped and rotated tiles render correctly with sprite batch:', () {
    late Uint8List canvasPixelData, canvasPixelDataAtlas;
    late RenderableTiledMap overlapMap;
    setUp(() async {
      Flame.bundle = TestAssetBundle(
        imageNames: [
          '4_color_sprite.png',
        ],
        mapPath: 'test/assets/8_tiles-flips.tmx',
      );
      overlapMap = await RenderableTiledMap.fromFile(
        '8_tiles-flips.tmx',
        Vector2.all(16),
      );
      final canvasRecorder = PictureRecorder();
      final canvas = Canvas(canvasRecorder);
      overlapMap.render(canvas);
      final picture = canvasRecorder.endRecording();

      final image = await picture.toImageSafe(64, 48);
      final bytes = await image.toByteData();
      canvasPixelData = bytes!.buffer.asUint8List();

      await Flame.images.ready();
      final canvasRecorderAtlas = PictureRecorder();
      final canvasAtlas = Canvas(canvasRecorderAtlas);
      overlapMap.render(canvasAtlas);
      final pictureAtlas = canvasRecorderAtlas.endRecording();

      final imageAtlas = await pictureAtlas.toImageSafe(64, 48);
      final bytesAtlas = await imageAtlas.toByteData();
      canvasPixelDataAtlas = bytesAtlas!.buffer.asUint8List();
    });

    test('[useAtlas = true] Green tile pixels are in correct spots', () {
      final leftTilePixels = <int>[];
      for (var i = 65 * 8 * 4; i < ((64 * 23) + (8 * 3)) * 4; i += 64 * 4) {
        leftTilePixels.addAll(canvasPixelDataAtlas.getRange(i, i + (16 * 4)));
      }

      var allGreen = true;
      for (var i = 0; i < leftTilePixels.length; i += 4) {
        allGreen &= leftTilePixels[i] == 0 &&
            leftTilePixels[i + 1] == 255 &&
            leftTilePixels[i + 2] == 0 &&
            leftTilePixels[i + 3] == 255;
      }
      expect(allGreen, true);

      final rightTilePixels = <int>[];
      for (var i = 69 * 8 * 4; i < ((64 * 23) + (8 * 7)) * 4; i += 64 * 4) {
        rightTilePixels.addAll(canvasPixelDataAtlas.getRange(i, i + (16 * 4)));
      }

      for (var i = 0; i < rightTilePixels.length; i += 4) {
        allGreen &= rightTilePixels[i] == 0 &&
            rightTilePixels[i + 1] == 255 &&
            rightTilePixels[i + 2] == 0 &&
            rightTilePixels[i + 3] == 255;
      }
      expect(allGreen, true);
    });

    test('[useAtlas = false] Green tile pixels are in correct spots', () {
      final leftTilePixels = <int>[];
      for (var i = 65 * 8 * 4; i < ((64 * 23) + (8 * 3)) * 4; i += 64 * 4) {
        leftTilePixels.addAll(canvasPixelData.getRange(i, i + (16 * 4)));
      }

      var allGreen = true;
      for (var i = 0; i < leftTilePixels.length; i += 4) {
        allGreen &= leftTilePixels[i] == 0 &&
            leftTilePixels[i + 1] == 255 &&
            leftTilePixels[i + 2] == 0 &&
            leftTilePixels[i + 3] == 255;
      }
      expect(allGreen, true);

      final rightTilePixels = <int>[];
      for (var i = 69 * 8 * 4; i < ((64 * 23) + (8 * 7)) * 4; i += 64 * 4) {
        rightTilePixels.addAll(canvasPixelData.getRange(i, i + (16 * 4)));
      }

      for (var i = 0; i < rightTilePixels.length; i += 4) {
        allGreen &= rightTilePixels[i] == 0 &&
            rightTilePixels[i + 1] == 255 &&
            rightTilePixels[i + 2] == 0 &&
            rightTilePixels[i + 3] == 255;
      }
      expect(allGreen, true);
    });
  });

  group('Test getLayer:', () {
    late RenderableTiledMap _renderableTiledMap;
    setUp(() async {
      Flame.bundle = TestAssetBundle(
        imageNames: ['map-level1.png'],
        mapPath: 'test/assets/layers_test.tmx',
      );
      _renderableTiledMap =
          await RenderableTiledMap.fromFile('layers_test.tmx', Vector2.all(32));
    });

    test('Get Tile Layer', () {
      expect(
        _renderableTiledMap.getLayer<TileLayer>('MyTileLayer'),
        isNotNull,
      );
    });

    test('Get Object Layer', () {
      expect(
        _renderableTiledMap.getLayer<ObjectGroup>('MyObjectLayer'),
        isNotNull,
      );
    });

    test('Get Image Layer', () {
      expect(
        _renderableTiledMap.getLayer<ImageLayer>('MyImageLayer'),
        isNotNull,
      );
    });

    test('Get Group Layer', () {
      expect(
        _renderableTiledMap.getLayer<Group>('MyGroupLayer'),
        isNotNull,
      );
    });

    test('Get no layer', () {
      expect(
        _renderableTiledMap.getLayer<TileLayer>('Nonexistent layer'),
        isNull,
      );
    });
  });

  Future<Uint8List> renderMapToPng(
    TiledComponent component,
    num width,
    num height,
  ) async {
    final canvasRecorder = PictureRecorder();
    final canvas = Canvas(canvasRecorder);
    component.tileMap.render(canvas);
    final picture = canvasRecorder.endRecording();

    // Map size is now 320 wide, but it has 1 extra tile of height becusae
    // its actually double-height tiles.
    final image = await picture.toImageSafe(width.toInt(), height.toInt());
    return (await image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  group('orthogonal with groups, offsets, opacity and parallax', () {
    late TiledComponent component;
    final mapSizePx = Vector2(32 * 16, 128 * 16);

    setUp(() async {
      Flame.bundle = TestAssetBundle(
        imageNames: [
          'image1.png',
          'map-level1.png',
        ],
        mapPath: 'test/assets/map.tmx',
      );
      component = await TiledComponent.load(
        'map.tmx',
        Vector2(16, 16),
      );

      // Need to initialize a game and call `onLoad` and `onGameResize` to
      // get the camera and canvas sizes all initialized
      final game = FlameGame(children: [component]);
      component.onLoad();
      component.onGameResize(mapSizePx);
      game.onGameResize(mapSizePx);
      game.camera.snapTo(Vector2(150, 20));
    });

    test('component size', () {
      expect(component.tileMap.destTileSize, Vector2(16, 16));
      expect(component.size, mapSizePx);
    });

    test('renders', () async {
      final pngData = await renderMapToPng(component, 32 * 16, 128 * 16);

      expect(pngData, matchesGoldenFile('goldens/orthogonal.png'));
    });
  });

  group('isometric', () {
    late TiledComponent component;

    setUp(() async {
      Flame.bundle = TestAssetBundle(
        imageNames: [
          'isometric_spritesheet.png',
        ],
        mapPath: 'test/assets/test_isometric.tmx',
      );
      component = await TiledComponent.load(
        'test_isometric.tmx',
        Vector2(256 / 4, 128 / 4),
      );
    });

    test('component size', () {
      expect(component.tileMap.destTileSize, Vector2(64, 32));
      expect(component.size, Vector2(64 * 5, 32 * 5));
    });

    test('renders', () async {
      // Map size is now 320 wide, but it has 1 extra tile of height becusae
      // its actually double-height tiles.
      final pngData =
          await renderMapToPng(component, 256 * 5 ~/ 4, (128 * 5 + 128) ~/ 4);

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
      Flame.bundle = TestAssetBundle(
        imageNames: [
          imageFile,
        ],
        mapPath: 'test/assets/$tmxFile',
      );
      return component = await TiledComponent.load(
        tmxFile,
        destTileSize,
      );
    }

    test('flat + even staggerd', () async {
      await setupMap(
        'flat_hex_even.tmx',
        'Tileset_Hexagonal_FlatTop_60x39_60x60.png',
        Vector2(60, 39),
      );

      expect(component.size, Vector2(240, 214.5));

      final pngData = await renderMapToPng(component, 240, 215);

      expect(pngData, matchesGoldenFile('goldens/flat_hex_even.png'));
    });

    test('flat + odd staggerd', () async {
      await setupMap(
        'flat_hex_odd.tmx',
        'Tileset_Hexagonal_FlatTop_60x39_60x60.png',
        Vector2(60, 39),
      );

      expect(component.size, Vector2(240, 214.5));

      final pngData = await renderMapToPng(component, 240, 215);

      expect(pngData, matchesGoldenFile('goldens/flat_hex_odd.png'));
    });

    test('pointy + even staggerd', () async {
      await setupMap(
        'pointy_hex_even.tmx',
        'Tileset_Hexagonal_PointyTop_60x52_60x80.png',
        Vector2(60, 52),
      );

      expect(component.size, Vector2(330, 208));

      final pngData = await renderMapToPng(component, 330, 208);

      expect(pngData, matchesGoldenFile('goldens/pointy_hex_even.png'));
    });

    test('pointy + odd staggerd', () async {
      await setupMap(
        'pointy_hex_odd.tmx',
        'Tileset_Hexagonal_PointyTop_60x52_60x80.png',
        Vector2(60, 52),
      );

      expect(component.size, Vector2(330, 208));

      final pngData = await renderMapToPng(component, 330, 208);

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
      Flame.bundle = TestAssetBundle(
        imageNames: [
          imageFile,
        ],
        mapPath: 'test/assets/$tmxFile',
      );
      return component = await TiledComponent.load(
        tmxFile,
        destTileSize,
      );
    }

    test('x + odd', () async {
      await setupMap(
        'iso_staggered_overlap_x_odd.tmx',
        'dirt_atlas.png',
        Vector2(128, 64),
      );

      expect(component.size, Vector2(320, 288));

      final pngData = await renderMapToPng(component, 320, 288);

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

      final pngData = await renderMapToPng(component, 160, 144);

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

      final pngData = await renderMapToPng(component, 288, 80);

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

      final pngData = await renderMapToPng(component, 576, 160);

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
      Flame.bundle = TestAssetBundle(
        imageNames: [
          'isometric_spritesheet.png',
        ],
        mapPath: 'test/assets/test_shifted.tmx',
      );
      component = await TiledComponent.load(
        'test_isometric.tmx',
        destTileSize,
      );
    }

    test('regular', () async {
      await setupMap(size);
      final pngData = await renderMapToPng(
        component,
        size.x.toInt() * 5,
        size.y.toInt() * 5,
      );

      expect(
        pngData,
        matchesGoldenFile('goldens/shifted_scaled_regular.png'),
      );
    });

    test('smaller', () async {
      final smallSize = size / 3;
      await setupMap(smallSize);
      final pngData = await renderMapToPng(
        component,
        smallSize.x.toInt() * 5,
        smallSize.y.toInt() * 5,
      );

      expect(
        pngData,
        matchesGoldenFile('goldens/shifted_scaled_smaller.png'),
      );
    });

    test('larger', () async {
      final largeSize = size * 2;
      await setupMap(largeSize);
      final pngData = await renderMapToPng(
        component,
        largeSize.x.toInt() * 5,
        largeSize.y.toInt() * 5,
      );

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
      Flame.bundle = TestAssetBundle(
        imageNames: [
          'isometric_spritesheet.png',
        ],
        mapPath: 'test/assets/test_isometric.tmx',
      );
      component = await TiledComponent.load('test_isometric.tmx', size);
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

      final pngData =
          await renderMapToPng(component, size.x * 5, size.y * 5 + size.y / 2);
      expect(
        pngData,
        matchesGoldenFile('goldens/tile_stack_all_move.png'),
      );
    });

    test('can be positioned singularly', () async {
      final stack = component.tileMap.tileStack(0, 0, named: {'item'});
      stack.position = stack.position + Vector2(-20, 20);

      final pngData = await renderMapToPng(component, size.x * 5, size.y * 5);
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

    setUp(() async {
      Flame.bundle = TestAssetBundle(
        imageNames: [
          '0x72_DungeonTilesetII_v1.4.png',
        ],
        mapPath: 'test/assets/dungeon_animation.tmx',
      );
      component = await TiledComponent.load('dungeon_animation.tmx', size);
      map = component.tileMap;
    });

    test('handle single frame animations', () {
      expect(map.renderableLayers.first, isInstanceOf<renderable.TileLayer>());
      final layer = map.renderableLayers.first as renderable.TileLayer;
      expect(
        layer.animations,
        hasLength(1),
        reason: 'layer has only one animation',
      );
      expect(
        layer.animationFrames,
        hasLength(1),
        reason: 'layer only caches frames in use',
      );
      expect(layer.animations.first.frames.sources, hasLength(1));
    });

    test('handle single frame animations', () {
      expect(map.renderableLayers[1], isInstanceOf<renderable.TileLayer>());
      final layer = map.renderableLayers[1] as renderable.TileLayer;
      expect(
        layer.animations,
        hasLength(2),
        reason: 'two animations on this layer',
      );
      expect(
        layer.animationFrames,
        hasLength(2),
        reason: 'layer only caches frames in use',
      );

      final waterAnimation = layer.animations.first;
      final spikeAnimation = layer.animations.last;
      expect(waterAnimation.frames.durations, [.18, .17, .15]);
      expect(spikeAnimation.frames.durations, [.176, .176, .176, .176]);

      layer.update(.177);
      expect(waterAnimation.frame, 0);
      expect(waterAnimation.frameTime, .177);
      expect(
        waterAnimation.batchedSource.toRect(),
        waterAnimation.frames.sources[0],
      );

      expect(spikeAnimation.frame, 1);
      expect(spikeAnimation.frameTime, moreOrLessEquals(.001));
      expect(
        spikeAnimation.batchedSource.toRect(),
        spikeAnimation.frames.sources[1],
      );

      layer.update(.003);
      expect(waterAnimation.frame, 1);
      expect(waterAnimation.frameTime, moreOrLessEquals(.0));
      expect(spikeAnimation.frame, 1);
      expect(spikeAnimation.frameTime, moreOrLessEquals(0.004));

      layer.update(0.17 + 0.15);
      expect(waterAnimation.frame, 0, reason: 'wraps around');
      expect(
        waterAnimation.batchedSource.toRect(),
        waterAnimation.frames.sources[0],
      );
    });

    test('renders', () async {
      var pngData = await renderMapToPng(component, size.x * 4, size.y * 1);
      expect(
        pngData,
        matchesGoldenFile('goldens/dungeon_animation_0.png'),
      );

      component.update(0.18);
      pngData = await renderMapToPng(component, size.x * 4, size.y * 1);
      expect(
        pngData,
        matchesGoldenFile('goldens/dungeon_animation_1.png'),
      );

      component.update(0.18);
      pngData = await renderMapToPng(component, size.x * 4, size.y * 1);
      expect(
        pngData,
        matchesGoldenFile('goldens/dungeon_animation_2.png'),
      );

      component.update(0.18);
      pngData = await renderMapToPng(component, size.x * 4, size.y * 1);
      expect(
        pngData,
        matchesGoldenFile('goldens/dungeon_animation_3.png'),
      );
    });
  });
}

class TestAssetBundle extends CachingAssetBundle {
  TestAssetBundle({
    required this.imageNames,
    required this.mapPath,
  });

  final List<String> imageNames;
  final String mapPath;

  @override
  Future<ByteData> load(String key) async {
    final split = key.split('/');
    final imgName = split.isNotEmpty ? split.last : key;

    var toLoadName = key.split('/').last;
    if (!imageNames.contains(imgName) && imageNames.isNotEmpty) {
      toLoadName = imageNames.first;
    }
    return File('test/assets/$toLoadName')
        .readAsBytes()
        .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    return File(mapPath).readAsString();
  }
}
