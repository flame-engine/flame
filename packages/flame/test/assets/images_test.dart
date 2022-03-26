import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockImage extends Mock implements Image {
  int disposedCount = 0;

  @override
  void dispose() {
    disposedCount++;
  }
}

void main() {
  // A simple 1x1 pixel encoded as base64 - just so that we have something to
  // load into the Images cache.
  const pixel =
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJA'
      'AAAAXNSR0IArs4c6QAAAA1JREFUGFdjWP33/n8ACGUDhwieHSEAAAAASUVORK5CYII=';

  group('Images', () {
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
      final image = MockImage();
      cache.add('test', image);
      expect(image.disposedCount, 0);
      cache.clear('test');
      expect(image.disposedCount, 1);
    });

    test('clearCache', () {
      final cache = Images();
      final images = List.generate(10, (_) => MockImage());
      for (var i = 0; i < images.length; i++) {
        cache.add(i.toString(), images[i]);
      }
      expect(images.fold<int>(0, (agg, image) => agg + image.disposedCount), 0);
      cache.clearCache();
      expect(
        images.fold<int>(0, (agg, image) => agg + image.disposedCount),
        images.length,
      );
    });

    testWithFlameGame(
      'prefix on game.images can be changed',
      (game) async {
        expect(game.images.prefix, 'assets/images/');
        game.images.prefix = 'assets/pictures/';
        expect(game.images.prefix, 'assets/pictures/');
        game.images.prefix = '';
        expect(game.images.prefix, '');
      },
    );

    test('throws when setting an invalid prefix', () {
      final images = Images();
      expect(
        () => images.prefix = 'adasd',
        failsAssert('Prefix must be empty or end with a "/"'),
      );
    });

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
  });
}
