import 'dart:io';

import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flame_texturepacker/src/model/region.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Index Pattern Parsing', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('atlas_test');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    Future<Iterable<Region>> createAndLoadRegions(String content) async {
      final atlasFile = File('${tempDir.path}/test.atlas');
      await atlasFile.writeAsString(content);

      final imageFile = File('${tempDir.path}/test.png');
      // Copy a real valid PNG from assets to avoid "Invalid image data" errors
      final realPngBytes = await File(
        'test/assets/whitelist/whitelist_test.png',
      ).readAsBytes();
      await imageFile.writeAsBytes(realPngBytes);

      final atlasData = await TexturePackerAtlas.loadAtlas(
        atlasFile.path,
        fromStorage: true,
      );
      return atlasData.regions;
    }

    test('Name with trailing digits is preserved as-is', () async {
      final regions = await createAndLoadRegions('''
test.png
size: 64, 64
format: RGBA8888
filter: Linear,Linear
repeat: none
image1
  rotate: false
  xy: 0, 0
  size: 32, 32
  orig: 32, 32
  offset: 0, 0
''');
      expect(regions.first.name, 'image1');
      expect(regions.first.index, -1);
    });

    test('Name with zero-padded trailing digits is preserved', () async {
      final regions = await createAndLoadRegions('''
test.png
size: 64, 64
format: RGBA8888
filter: Linear,Linear
repeat: none
image01
  rotate: false
  xy: 0, 0
  size: 32, 32
  orig: 32, 32
  offset: 0, 0
''');
      expect(regions.first.name, 'image01');
      expect(regions.first.index, -1);
    });

    test('Name with underscore and digit is preserved', () async {
      final regions = await createAndLoadRegions('''
test.png
size: 64, 64
format: RGBA8888
filter: Linear,Linear
repeat: none
image_1
  rotate: false
  xy: 0, 0
  size: 32, 32
  orig: 32, 32
  offset: 0, 0
''');
      expect(regions.first.name, 'image_1');
      expect(regions.first.index, -1);
    });

    test('Name with underscore and zero-padded digit is preserved', () async {
      final regions = await createAndLoadRegions('''
test.png
size: 64, 64
format: RGBA8888
filter: Linear,Linear
repeat: none
image_01
  rotate: false
  xy: 0, 0
  size: 32, 32
  orig: 32, 32
  offset: 0, 0
''');
      expect(regions.first.name, 'image_01');
      expect(regions.first.index, -1);
    });

    test('Name with triple-zero-padded digit is preserved', () async {
      final regions = await createAndLoadRegions('''
test.png
size: 64, 64
format: RGBA8888
filter: Linear,Linear
repeat: none
image001
  rotate: false
  xy: 0, 0
  size: 32, 32
  orig: 32, 32
  offset: 0, 0
''');
      expect(regions.first.name, 'image001');
      expect(regions.first.index, -1);
    });

    test('Explicit index field is used when present', () async {
      final regions = await createAndLoadRegions('''
test.png
size: 64, 64
format: RGBA8888
filter: Linear,Linear
repeat: none
image_01
  rotate: false
  xy: 0, 0
  size: 32, 32
  orig: 32, 32
  offset: 0, 0
  index: 5
''');
      expect(regions.first.name, 'image_01');
      expect(regions.first.index, 5);
    });
  });
}
