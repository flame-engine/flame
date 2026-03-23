import 'dart:io';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Separated Parsing and Loading', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('atlas_test');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    const atlasContent = '''
test.png
size: 64, 64
format: RGBA8888
filter: Linear,Linear
repeat: none
sprite1
  rotate: false
  xy: 0, 0
  size: 32, 32
  orig: 32, 32
  offset: 0, 0
  index: 1
''';

    test('should parse atlas metadata without loading images', () async {
      final atlasFile = File('${tempDir.path}/test.atlas');
      await atlasFile.writeAsString(atlasContent);

      // We don't even need the image file to exist if we don't load images
      final atlasData = await TexturePackerAtlas.loadAtlas(
        atlasFile.path,
        fromStorage: true,
        loadImages: false,
      );

      expect(atlasData.pages, hasLength(1));
      expect(atlasData.pages.first.textureFile, 'test.png');
      expect(atlasData.pages.first.texture, isNull);
      expect(atlasData.regions, hasLength(1));
      // 'sprite1' becomes 'sprite' with index 1
      expect(atlasData.regions.first.name, 'sprite');
      expect(atlasData.regions.first.index, 1);
    });

    test('should load images later for already parsed atlas data', () async {
      final atlasFile = File('${tempDir.path}/test.atlas');
      await atlasFile.writeAsString(atlasContent);

      final imageFile = File('${tempDir.path}/test.png');
      // Use a real PNG for decoding
      final realPngBytes = await File(
        'test/assets/whitelist/whitelist_test.png',
      ).readAsBytes();
      await imageFile.writeAsBytes(realPngBytes);

      // 1. Initial parse without images
      final atlasData = await TexturePackerAtlas.loadAtlas(
        atlasFile.path,
        fromStorage: true,
        loadImages: false,
      );
      expect(atlasData.pages.first.texture, isNull);

      // 2. Load images later
      await TexturePackerParser.loadAtlasDataImages(
        atlasData,
        atlasFile.path,
        fromStorage: true,
      );

      expect(atlasData.pages.first.texture, isNotNull);

      // 3. Create atlas from data
      final atlas = TexturePackerAtlas.fromAtlas(atlasData);
      expect(atlas.sprites, hasLength(1));
      expect(atlas.sprites.first.region.name, 'sprite');
    });

    test('getAnimation provides sequences easily', () async {
      const animationAtlas = '''
anim.png
size: 64, 64
format: RGBA8888
filter: Linear,Linear
repeat: none
walk_0
  rotate: false
  xy: 0, 0
  size: 32, 32
  orig: 32, 32
  offset: 0, 0
  index: 0
walk_1
  rotate: false
  xy: 32, 0
  size: 32, 32
  orig: 32, 32
  offset: 0, 0
  index: 1
''';
      final atlasFile = File('${tempDir.path}/anim.atlas');
      await atlasFile.writeAsString(animationAtlas);

      final imageFile = File('${tempDir.path}/anim.png');
      final realPngBytes = await File(
        'test/assets/whitelist/whitelist_test.png',
      ).readAsBytes();
      await imageFile.writeAsBytes(realPngBytes);

      final atlasData = await TexturePackerAtlas.loadAtlas(
        atlasFile.path,
        fromStorage: true,
      );
      final atlas = TexturePackerAtlas.fromAtlas(atlasData);

      final animation = atlas.getAnimation('walk');
      expect(animation.frames.length, equals(2));
    });
  });
}
