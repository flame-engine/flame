import 'dart:convert';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // A simple 1x1 pixel encoded as base64 - just so that we have something to
  // load into the Images cache.
  const pixel =
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJA'
      'AAAAXNSR0IArs4c6QAAAA1JREFUGFdjWP33/n8ACGUDhwieHSEAAAAASUVORK5CYII=';

  group('Images', () {
    test('can add a base64 image to the cache', () async {
      final cache = Images();
      await cache.addFromBase64Data('img', pixel);

      expect(cache.fromCache('img'), isA<Image>());
    });

    test('load image', () async {
      final cache = Images();
      final image = await cache.fromBase64('img', pixel);
      expect(image, isA<Image>());
      expect(cache.fromCache('img'), image);
    });

    test('access non-existent image', () {
      final cache = Images();
      expect(
        () => cache.fromCache('image'),
        failsAssert(
          'Tried to access an image "image" that does not exist in the cache. '
          'Make sure to load() an image before accessing it',
        ),
      );
    });

    test('access non-yet-loaded image', () {
      final cache = Images();
      cache.fromBase64('image', pixel); // did not await
      expect(
        () => cache.fromCache('image'),
        failsAssert(
          'Tried to access an image "image" before it was loaded. '
          'Make sure to await the future from load() before using this method',
        ),
      );
    });

    test('clear', () {
      final cache = Images();
      final image = _MockImage();
      cache.add('test', image);
      expect(image.disposedCount, 0);
      cache.clear('test');
      expect(image.disposedCount, 1);
    });

    test('clearCache', () {
      final cache = Images();
      final images = List.generate(10, (_) => _MockImage());
      for (var i = 0; i < images.length; i++) {
        cache.add(i.toString(), images[i]);
      }
      expect(images.map((image) => image.disposedCount).sum, 0);
      cache.clearCache();
      expect(images.map((image) => image.disposedCount).sum, images.length);
    });

    test('contains', () {
      final cache = Images();
      final images = List.generate(10, (_) => _MockImage());
      for (var i = 0; i < images.length; i++) {
        final key = i.toString();
        cache.add(key, images[i]);
        expect(cache.containsKey(key), isTrue);
      }
      cache.clearCache();
      for (var i = 0; i < images.length; i++) {
        expect(cache.containsKey(i.toString()), isFalse);
      }
    });

    test('keys', () {
      final cache = Images();
      final images = List.generate(10, (_) => _MockImage());
      for (var i = 0; i < images.length; i++) {
        cache.add(i.toString(), images[i]);
      }
      expect(
        cache.keys.toSet(),
        {for (var i = 0; i < images.length; i++) i.toString()},
      );
    });

    testWithFlameGame(
      'Game.images is same as Flame.images',
      (game) async {
        expect(game.images, equals(Flame.images));

        final img = _MockImage();
        game.images.add('my image', img);
        expect(Flame.images.containsKey('my image'), isTrue);
        expect(Flame.images.keys, hasLength(1));

        game.images = Images();
        game.images.add('new image', img);
        expect(Flame.images.containsKey('new image'), isFalse);
      },
    );

    test('.ready()', () async {
      final images = Images();
      images.fromBase64('image1', pixel);
      images.fromBase64('image2', pixel);
      expect(() => images.fromCache('image1'), failsAssert());
      expect(() => images.fromCache('image2'), failsAssert());
      await images.ready();
      expect(images.fromCache('image1'), isNotNull);
      expect(images.fromCache('image2'), isNotNull);
    });

    test('loads from a package', () async {
      final bundle = _MockAssetBundle();
      when(() => bundle.load(any())).thenAnswer(
        (_) async {
          final list = base64Decode(pixel.split(',').last);
          return ByteData.view(list.buffer);
        },
      );

      final images = Images(bundle: bundle);
      await images.load('assets/images/pixel.png', package: 'my_pkg');

      verify(
        () => bundle.load('packages/my_pkg/assets/images/pixel.png'),
      ).called(1);
    });

    test('can have its bundle overridden', () async {
      final bundle = _MockAssetBundle();
      when(() => bundle.load(any())).thenAnswer(
        (_) async {
          final list = base64Decode(pixel.split(',').last);
          return ByteData.view(list.buffer);
        },
      );

      final images = Images(bundle: bundle);
      final image = await images.load('assets/images/pixel.png');

      expect(image.width, equals(1));
      expect(image.height, equals(1));

      verify(() => bundle.load('assets/images/pixel.png')).called(1);
    });

    group('loadAllFromPattern', () {
      _ManifestAssetBundle bundleWith(List<String> paths) {
        return _ManifestAssetBundle(
          paths,
          base64Decode(pixel.split(',').last),
        );
      }

      test('only loads assets under the given directory', () async {
        final bundle = bundleWith([
          'assets/images/player.png',
          'assets/images/enemy.jpg',
          'assets/images/notes.txt',
          'assets/tiles/map.png',
          'packages/other/assets/images/logo.png',
        ]);
        final images = Images(bundle: bundle);

        await images.loadAllImages(directory: 'assets/images/');

        expect(
          images.keys.toSet(),
          {'assets/images/player.png', 'assets/images/enemy.jpg'},
        );
      });

      test('caches entries under their full manifest path', () async {
        final bundle = bundleWith(['assets/images/nested/player.png']);
        final images = Images(bundle: bundle);

        await images.loadAllImages(directory: 'assets/images/');

        expect(images.keys, equals(['assets/images/nested/player.png']));
        expect(bundle.loadedKeys, equals(['assets/images/nested/player.png']));
      });

      test('an empty directory matches the whole bundle', () async {
        final bundle = bundleWith([
          'assets/images/player.png',
          'assets/tiles/map.png',
        ]);
        final images = Images(bundle: bundle);

        await images.loadAllImages(directory: '');

        expect(
          images.keys.toSet(),
          {'assets/images/player.png', 'assets/tiles/map.png'},
        );
      });

      test('throws when the directory does not end with a slash', () {
        final images = Images(bundle: bundleWith([]));
        expect(
          () => images.loadAllImages(directory: 'assets/images'),
          failsAssert('directory must be empty or end with a "/"'),
        );
      });
    });

    test('the same file in two packages does not collide', () async {
      final bundle = _MockAssetBundle();
      when(() => bundle.load(any())).thenAnswer(
        (_) async {
          final list = base64Decode(pixel.split(',').last);
          return ByteData.view(list.buffer);
        },
      );

      final images = Images(bundle: bundle);
      await images.load('assets/images/pixel.png', package: 'pkg_a');
      await images.load('assets/images/pixel.png', package: 'pkg_b');

      expect(images.keys.toSet(), {
        'packages/pkg_a/assets/images/pixel.png',
        'packages/pkg_b/assets/images/pixel.png',
      });
      verify(
        () => bundle.load('packages/pkg_a/assets/images/pixel.png'),
      ).called(1);
      verify(
        () => bundle.load('packages/pkg_b/assets/images/pixel.png'),
      ).called(1);
    });
  });
}

class _ManifestAssetBundle extends CachingAssetBundle {
  _ManifestAssetBundle(this.assetPaths, this.pixelBytes);

  final List<String> assetPaths;
  final Uint8List pixelBytes;

  final List<String> loadedKeys = [];

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage(<String, Object?>{
        for (final path in assetPaths) path: <Object?>[],
      })!;
    }
    loadedKeys.add(key);
    return ByteData.view(pixelBytes.buffer);
  }
}

class _MockImage extends Mock implements Image {
  int disposedCount = 0;

  @override
  void dispose() {
    disposedCount++;
  }
}
