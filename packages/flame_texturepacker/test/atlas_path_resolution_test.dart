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

      when(() => images.prefix).thenReturn('assets/images/');
    });

    test('should resolve paths correctly with leading slashes', () async {
      final assets = AssetsCache(bundle: bundle);

      await TexturePackerAtlas.load(
        '/path/to/atlas_name.atlas',
        assets: assets,
        images: images,
      );

      // Verify it tried to load 'images/path/to/atlas.atlas'
      // The leading slash in /path/to/atlas.atlas should be removed.
      verify(
        () => bundle.loadString(
          'assets/images/path/to/atlas_name.atlas',
          cache: any(named: 'cache'),
        ),
      ).called(1);
    });

    test('should handle assetsPrefix WITH trailing slash', () async {
      final assets = AssetsCache(bundle: bundle);

      await TexturePackerAtlas.load(
        'atlas_name.atlas',
        assetsPrefix: 'custom/',
        assets: assets,
        images: images,
      );

      verify(
        () => bundle.loadString(
          'assets/custom/atlas_name.atlas',
          cache: any(named: 'cache'),
        ),
      ).called(1);
    });

    test('should not apply assetsPrefix to image paths loaded via Images',
        () async {
      final assets = AssetsCache(bundle: bundle);

      await TexturePackerAtlas.load(
        'atlas_name.atlas',
        assets: assets,
        images: images,
      );

      // assetsPrefix is for Flame.assets (prefix 'assets/'), NOT for
      // Flame.images (prefix 'assets/images/'). The image path must be
      // relative to Flame.images's prefix, without assetsPrefix applied.
      verify(
        () => images.load('test.png', package: any(named: 'package')),
      ).called(1);
    });

    test(
      'should not double-prefix image paths in subdirectories',
      () async {
        final assets = AssetsCache(bundle: bundle);
        const subDirAtlasContent = '''
textures.png
size: 64, 64
filter: Nearest, Nearest
repeat: none
sprite1
  bounds: 0, 0, 32, 32
''';

        when(
          () => bundle.loadString(any(), cache: any(named: 'cache')),
        ).thenAnswer((_) async => subDirAtlasContent);

        await TexturePackerAtlas.load(
          'packs/atlas_name.atlas',
          assets: assets,
          images: images,
        );

        // The image path should be 'packs/textures.png' (parent dir + filename),
        // NOT 'images/packs/textures.png' which would cause Flame.images to
        // resolve 'assets/images/images/packs/textures.png'.
        verify(
          () => images.load(
            'packs/textures.png',
            package: any(named: 'package'),
          ),
        ).called(1);
      },
    );

    test('should handle assetsPrefix WITHOUT trailing slash', () async {
      final assets = AssetsCache(bundle: bundle);

      await TexturePackerAtlas.load(
        'atlas_name.atlas',
        assetsPrefix: 'custom',
        assets: assets,
        images: images,
      );

      verify(
        () => bundle.loadString(
          'assets/custom/atlas_name.atlas',
          cache: any(named: 'cache'),
        ),
      ).called(1);
    });

    test('should pass package parameter to AssetsCache and Images', () async {
      final assets = AssetsCache(bundle: bundle);

      await TexturePackerAtlas.load(
        'atlas_name.atlas',
        assets: assets,
        images: images,
        package: 'my_package',
      );

      // Verify bundle call includes the package-prefixed path
      verify(
        () => bundle.loadString(
          'packages/my_package/assets/images/atlas_name.atlas',
          cache: any(named: 'cache'),
        ),
      ).called(1);

      // Verify images.load call also includes the package
      verify(
        () => images.load('test.png', package: 'my_package'),
      ).called(1);
    });

    test(
      'should auto-detect package from path if package parameter is null',
      () async {
        final assets = AssetsCache(bundle: bundle);

        await TexturePackerAtlas.load(
          'packages/custom_package/assets/images/atlas_name.atlas',
          assets: assets,
          images: images,
        );

        // Verify bundle call extracted 'custom_package' and cleaned the path
        verify(
          () => bundle.loadString(
            'packages/custom_package/assets/images/atlas_name.atlas',
            cache: any(named: 'cache'),
          ),
        ).called(1);

        // Verify images.load also uses the extracted package
        verify(
          () => images.load('test.png', package: 'custom_package'),
        ).called(1);
      },
    );

    test(
      'should load correctly when full assets/ path is provided with empty prefix',
      () async {
        final assets = AssetsCache(bundle: bundle);

        await TexturePackerAtlas.load(
          'assets/images/atlas_name.atlas',
          assetsPrefix: '',
          assets: assets,
          images: images,
        );

        verify(
          () => bundle.loadString(
            'assets/images/atlas_name.atlas',
            cache: any(named: 'cache'),
          ),
        ).called(1);
      },
    );

    test(
      'should handle redundant images/ prefix in atlas file for page images',
      () async {
        final assets = AssetsCache(bundle: bundle);
        const redundantAtlasContent = '''
images/test.png
size: 64, 64
filter: Nearest, Nearest
repeat: none
sprite1
  bounds: 0, 0, 32, 32
''';

        when(
          () => bundle.loadString(any(), cache: any(named: 'cache')),
        ).thenAnswer((_) async => redundantAtlasContent);

        await TexturePackerAtlas.load(
          'atlas_name.atlas',
          assets: assets,
          images: images,
        );

        // Verify images.load call strips the redundant 'images/' from inside the atlas
        verify(
          () => images.load('test.png', package: any(named: 'package')),
        ).called(1);
      },
    );

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
          'knight.atlas',
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
