import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart' show CachingAssetBundle;
import 'package:test/test.dart';
import 'package:tiled/tiled.dart';

void main() {
  test('correct loads the file', () async {
    Flame.bundle = TestAssetBundle(
      imageNames: ['map-level1.png'],
      mapPath: 'test/assets/map.tmx',
    );
    final tiled = await TiledComponent.load('x', Vector2.all(16));
    expect(tiled.tileMap.renderableLayers.length == 1, true);
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
