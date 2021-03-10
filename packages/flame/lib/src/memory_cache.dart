import 'dart:collection';

/// Simple class to cache values with size based eviction.
///
class MemoryCache<K, V> {
  final LinkedHashMap<K, V> _cache = LinkedHashMap();
  final int cacheSize;

  MemoryCache({this.cacheSize = 10});

  void setValue(K key, V value) {
    if (!_cache.containsKey(key)) {
      _cache[key] = value;

      while (_cache.length > cacheSize) {
        final k = _cache.keys.first;
        _cache.remove(k);
      }
    }
  }

  V? getValue(K key) => _cache[key];

  bool containsKey(K key) => _cache.containsKey(key);

  int get size => _cache.length;
}
