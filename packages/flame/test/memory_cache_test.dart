import 'package:test/test.dart';

import 'package:flame/src/memory_cache.dart';

void main() {
  group('MemoryCache', () {
    test('basic cache addition', () {
      final cache = MemoryCache<int, String>();
      cache.setValue(0, 'bla');
      expect(cache.getValue(0), 'bla');
    });

    test('contains key', () {
      final cache = MemoryCache<int, String>();
      cache.setValue(0, 'bla');
      expect(cache.containsKey(0), true);
      expect(cache.containsKey(1), false);
    });

    test('cache size', () {
      final cache = MemoryCache<int, String>(cacheSize: 1);
      cache.setValue(0, 'bla');
      cache.setValue(1, 'ble');
      expect(cache.containsKey(0), false);
      expect(cache.containsKey(1), true);
      expect(cache.getValue(0), null);
      expect(cache.getValue(1), 'ble');
      expect(cache.size, 1);
    });
  });
}
