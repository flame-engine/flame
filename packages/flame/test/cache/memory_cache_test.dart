import 'package:flame/cache.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryCache', () {
    test('basic cache access', () {
      final cache = MemoryCache<int, String>();
      cache.setValue(0, 'bla');
      expect(cache.getValue(0), 'bla');
    });

    test('containsKey', () {
      final cache = MemoryCache<int, String>();
      expect(cache.keys.length, 0);
      cache.setValue(0, 'bla');
      expect(cache.containsKey(0), true);
      expect(cache.containsKey(1), false);
      expect(cache.keys.length, 1);
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
