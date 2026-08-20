import 'dart:ui' as ui;
import 'package:flame/cache.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAssetBundle extends Mock implements AssetBundle {}

class _MockImages extends Mock implements Images {}

class FakeImage extends Mock implements ui.Image {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TexturePackerAtlas Path Resolution', () {
    late _MockAssetBundle bundle;
    late _MockImages images;
    late String atlasContent;

    setUpAll(() {
      registerFallbackValue(const Symbol('package'));
    });

    setUp(() {
      bundle = _MockAssetBundle();
      images = _MockImages();
      atlasContent = '''
test.png
size: 64, 64
filter: Nearest, Nearest
repeat: none
sprite1
  bounds: 0, 0, 32, 32
''';

      // Mock loading the atlas file
      when(
        () => bundle.loadString(any(), cache: any(named: 'cache')),
      ).thenAnswer((_) async => atlasContent);

      // Mock loading an image
      when(
        () => images.load(any(), package: any(named: 'package')),
      ).thenAnswer((_) async => FakeImage());
    });

    test('loads the atlas from the path exactly as given', () async {
      final assets = AssetsCache(bundle: bundle);

      await TexturePackerAtlas.load(
        'assets/images/atlas_name.atlas',
        assets: assets,
        images: images,
      );

      verify(
        () => bundle.loadString(
          'assets/images/atlas_name.atlas',
          cache: any(named: 'cache'),
        ),
      ).called(1);
    });

    test('resolves page textures relative to the atlas directory', () async {
      final assets = AssetsCache(bundle: bundle);

      await TexturePackerAtlas.load(
        'assets/atlases/atlas_name.atlas',
        assets: assets,
        images: images,
      );

      verify(
        () => images.load(
          'assets/atlases/test.png',
          package: any(named: 'package'),
        ),
      ).called(1);
    });

    test('resolves a page texture with no atlas directory', () async {
      final assets = AssetsCache(bundle: bundle);

      await TexturePackerAtlas.load(
        'atlas_name.atlas',
        assets: assets,
        images: images,
      );

      verify(
        () => images.load('test.png', package: any(named: 'package')),
      ).called(1);
    });

    test('honours a relative page texture path literally', () async {
      final assets = AssetsCache(bundle: bundle);
      const nestedAtlasContent = '''
pages/test.png
size: 64, 64
filter: Nearest, Nearest
repeat: none
sprite1
  bounds: 0, 0, 32, 32
''';

      when(
        () => bundle.loadString(any(), cache: any(named: 'cache')),
      ).thenAnswer((_) async => nestedAtlasContent);

      await TexturePackerAtlas.load(
        'assets/images/atlas_name.atlas',
        assets: assets,
        images: images,
      );

      verify(
        () => images.load(
          'assets/images/pages/test.png',
          package: any(named: 'package'),
        ),
      ).called(1);
    });

    test('passes the package through to both caches', () async {
      final assets = AssetsCache(bundle: bundle);

      await TexturePackerAtlas.load(
        'assets/images/atlas_name.atlas',
        assets: assets,
        images: images,
        package: 'my_package',
      );

      verify(
        () => bundle.loadString(
          'packages/my_package/assets/images/atlas_name.atlas',
          cache: any(named: 'cache'),
        ),
      ).called(1);

      verify(
        () => images.load(
          'assets/images/test.png',
          package: 'my_package',
        ),
      ).called(1);
    });

    test('loads a path that already points inside a package', () async {
      final assets = AssetsCache(bundle: bundle);

      await TexturePackerAtlas.load(
        'packages/custom_package/assets/images/atlas_name.atlas',
        assets: assets,
        images: images,
      );

      verify(
        () => bundle.loadString(
          'packages/custom_package/assets/images/atlas_name.atlas',
          cache: any(named: 'cache'),
        ),
      ).called(1);

      verify(
        () => images.load(
          'packages/custom_package/assets/images/test.png',
          package: any(named: 'package'),
        ),
      ).called(1);
    });

    test(
      'should correctly parse region names with .png and extracted indexes',
      () async {
        final assets = AssetsCache(bundle: bundle);
        const complexAtlasContent = '''
knight.png
size: 64, 64
filter: Nearest, Nearest
repeat: none
knight_walk_01.png
  bounds: 0, 0, 32, 32
knight_walk_02.png
  bounds: 32, 0, 32, 32
''';

        when(
          () => bundle.loadString(any(), cache: any(named: 'cache')),
        ).thenAnswer((_) async => complexAtlasContent);

        final atlas = await TexturePackerAtlas.load(
          'assets/images/knight.atlas',
          assets: assets,
          images: images,
        );

        expect(atlas.sprites.length, 2);
        expect(atlas.sprites[0].region.name, 'knight_walk');
        expect(atlas.sprites[0].region.index, 1);
        expect(atlas.sprites[1].region.name, 'knight_walk');
        expect(atlas.sprites[1].region.index, 2);
      },
    );
  });
}
