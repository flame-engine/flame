import 'package:clock/clock.dart';
import 'package:flame/cache.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Runs [body] as if [duration] had passed since the real time now.
  T later<T>(Duration duration, T Function() body) {
    return withClock(Clock.fixed(DateTime.now().add(duration)), body);
  }

  group('Images eviction', () {
    group('retain and release', () {
      test('count the references of an image', () async {
        final cache = Images();
        final image = await generateImage();
        cache.add('img', image);
        expect(cache.retainCount('img'), 0);

        cache.retain(image);
        expect(cache.retainCount('img'), 1);
        cache.retain(image);
        expect(cache.retainCount('img'), 2);

        cache.release(image);
        expect(cache.retainCount('img'), 1);
        cache.release(image);
        expect(cache.retainCount('img'), 0);
      });

      test('retaining a clone retains the original', () async {
        final cache = Images();
        final image = await generateImage();
        cache.add('img', image);
        final clone = image.clone();

        cache.retain(clone);
        expect(cache.retainCount('img'), 1);
        cache.release(clone);
        expect(cache.retainCount('img'), 0);
        clone.dispose();
      });

      test('ignore images that belong to another cache', () async {
        final cache = Images();
        final otherCache = Images();
        final image = await generateImage();
        otherCache.add('img', image);

        cache.retain(image);
        expect(cache.retainCount('img'), 0);
        expect(otherCache.retainCount('img'), 0);
        cache.release(image);
      });

      test('ignore images that belong to no cache', () async {
        final cache = Images();
        final image = await generateImage();

        expect(() => cache.retain(image), returnsNormally);
        expect(() => cache.release(image), returnsNormally);
        image.dispose();
      });

      test('releasing more than retained fails an assert', () async {
        final cache = Images();
        final image = await generateImage();
        cache.add('img', image);

        expect(
          () => cache.release(image),
          failsAssert(
            'Tried to release the image "img" more times than it was retained',
          ),
        );
      });

      test('unknown keys have a retain count of zero', () {
        final cache = Images();
        expect(cache.retainCount('nope'), 0);
      });
    });

    group('ownerOf', () {
      test('finds the cache that an image was loaded into', () async {
        final cache = Images();
        final image = await generateImage();
        cache.add('img', image);

        expect(Images.ownerOf(image), same(cache));
      });

      test('is null for images that belong to no cache', () async {
        final image = await generateImage();
        expect(Images.ownerOf(image), isNull);
        image.dispose();
      });

      test('is null once the image was cleared from the cache', () async {
        final cache = Images();
        final image = await generateImage();
        cache.add('img', image);
        cache.clear('img');

        expect(Images.ownerOf(image), isNull);
      });
    });

    group('sizeBytes', () {
      test('estimates four bytes per pixel', () async {
        final cache = Images();
        cache.add('a', await generateImage(10, 20));
        cache.add('b', await generateImage(2, 2));

        expect(cache.sizeBytesOf('a'), 800);
        expect(cache.sizeBytesOf('b'), 16);
        expect(cache.sizeBytesOf('nope'), 0);
        expect(cache.sizeBytes, 816);
      });

      test('does not count images that are still loading', () async {
        final cache = Images();
        final pending = cache.fetchOrGenerate('a', () => generateImage(10, 10));

        expect(cache.sizeBytesOf('a'), 0);
        expect(cache.sizeBytes, 0);
        await pending;
        expect(cache.sizeBytes, 400);
      });
    });

    group('evictUnused', () {
      test(
        'disposes images that are not retained once the grace period passed',
        () async {
          final cache = Images();
          cache.add('a', await generateImage(2, 2));
          cache.add('b', await generateImage(3, 3));

          final freed = later(const Duration(seconds: 10), cache.evictUnused);

          expect(freed, 16 + 36);
          expect(cache.containsKey('a'), isFalse);
          expect(cache.containsKey('b'), isFalse);
          expect(cache.sizeBytes, 0);
        },
      );

      test('keeps images that were used within the grace period', () async {
        final cache = Images();
        cache.add('a', await generateImage());

        expect(cache.evictUnused(), 0);
        expect(cache.containsKey('a'), isTrue);

        later(const Duration(seconds: 4), () => cache.fromCache('a'));
        expect(later(const Duration(seconds: 8), cache.evictUnused), 0);
        expect(cache.containsKey('a'), isTrue);

        expect(later(const Duration(seconds: 10), cache.evictUnused), 4);
        expect(cache.containsKey('a'), isFalse);
      });

      test('honors a custom grace period', () async {
        final cache = Images()..gracePeriod = Duration.zero;
        cache.add('a', await generateImage());

        expect(cache.evictUnused(), 4);
        expect(cache.containsKey('a'), isFalse);
      });

      test('keeps retained images', () async {
        final cache = Images()..gracePeriod = Duration.zero;
        final retained = await generateImage();
        cache.add('retained', retained);
        cache.add('loose', await generateImage());
        cache.retain(retained);

        expect(cache.evictUnused(), 4);
        expect(cache.containsKey('retained'), isTrue);
        expect(cache.containsKey('loose'), isFalse);

        cache.release(retained);
        expect(cache.evictUnused(), 4);
        expect(cache.containsKey('retained'), isFalse);
      });

      test('skips images that are still loading', () async {
        final cache = Images()..gracePeriod = Duration.zero;
        final pending = cache.fetchOrGenerate('a', generateImage);

        expect(cache.evictUnused(), 0);
        expect(cache.containsKey('a'), isTrue);
        await pending;
        expect(cache.evictUnused(), 4);
      });

      test('disposes the evicted image', () async {
        final cache = Images()..gracePeriod = Duration.zero;
        final image = await generateImage();
        cache.add('a', image);

        cache.evictUnused();

        expect(image.debugDisposed, isTrue);
      });

      test('fromCache fails with a helpful message afterwards', () async {
        final cache = Images()..gracePeriod = Duration.zero;
        cache.add('a', await generateImage());
        cache.evictUnused();

        expect(
          () => cache.fromCache('a'),
          failsAssert(
            'Tried to access an image "a" that has been evicted from the '
            'cache. Use load() to get images when eviction is enabled, or '
            'retain() the image while you keep a reference to it',
          ),
        );
      });

      test('the image can be loaded again afterwards', () async {
        final cache = Images()..gracePeriod = Duration.zero;
        final first = await cache.fetchOrGenerate('a', generateImage);
        cache.evictUnused();

        final second = await cache.fetchOrGenerate('a', generateImage);

        expect(second, isNot(same(first)));
        expect(cache.fromCache('a'), same(second));
        expect(cache.containsKey('a'), isTrue);
      });
    });

    group('maxSizeBytes', () {
      test('evicts the least recently used images over budget', () async {
        final cache = Images(maxSizeBytes: 32)..gracePeriod = Duration.zero;
        cache.add('a', await generateImage(2, 2));
        cache.add('b', await generateImage(2, 2));
        expect(cache.keys, ['a', 'b']);

        later(const Duration(seconds: 1), () => cache.fromCache('a'));
        later(
          const Duration(seconds: 2),
          () async => cache.add('c', await generateImage(2, 2)),
        );
        await cache.ready();

        expect(cache.keys, ['a', 'c']);
        expect(cache.sizeBytes, 32);
      });

      test('evicts when a load completes', () async {
        final cache = Images(maxSizeBytes: 16)..gracePeriod = Duration.zero;
        cache.add('a', await generateImage(2, 2));

        await later(
          const Duration(seconds: 1),
          () => cache.fetchOrGenerate('b', () => generateImage(2, 2)),
        );

        expect(cache.keys, ['b']);
      });

      test('never evicts retained images', () async {
        final cache = Images(maxSizeBytes: 16)..gracePeriod = Duration.zero;
        final retained = await generateImage(2, 2);
        cache.add('a', retained);
        cache.retain(retained);

        cache.add('b', await generateImage(2, 2));

        expect(cache.keys, ['a']);
        expect(cache.sizeBytes, 16);
      });

      test('keeps images within the grace period over budget', () async {
        final cache = Images(maxSizeBytes: 16);
        cache.add('a', await generateImage(2, 2));
        cache.add('b', await generateImage(2, 2));

        expect(cache.keys, ['a', 'b']);
        expect(cache.sizeBytes, 32);
      });

      test('is enforced when it is set', () async {
        final cache = Images()..gracePeriod = Duration.zero;
        cache.add('a', await generateImage(2, 2));
        cache.add('b', await generateImage(2, 2));

        cache.maxSizeBytes = 16;

        expect(cache.keys.length, 1);
        expect(cache.sizeBytes, 16);
      });

      test('does nothing when unset', () async {
        final cache = Images()..gracePeriod = Duration.zero;
        for (var i = 0; i < 10; i++) {
          cache.add('$i', await generateImage(10, 10));
        }

        expect(cache.keys.length, 10);
      });
    });

    test('clearCache removes retained images', () async {
      final cache = Images();
      final image = await generateImage();
      cache.add('a', image);
      cache.retain(image);

      cache.clearCache();

      expect(cache.containsKey('a'), isFalse);
      expect(image.debugDisposed, isTrue);
      expect(() => cache.release(image), returnsNormally);
    });

    test('clear removes retained images', () async {
      final cache = Images();
      final image = await generateImage();
      cache.add('a', image);
      cache.retain(image);

      cache.clear('a');

      expect(cache.containsKey('a'), isFalse);
      expect(() => cache.release(image), returnsNormally);
    });

    test('findKeyForImage finds the key through the cache entry', () async {
      final cache = Images();
      final image = await generateImage();
      cache.add('a', image);

      expect(cache.findKeyForImage(image), 'a');
      expect(cache.findKeyForImage(image.clone()), 'a');
    });
  });
}
