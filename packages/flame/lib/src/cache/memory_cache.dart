import 'dart:collection';

/// Simple class to cache values with size based eviction.
class MemoryCache<K, V> {
  final LinkedHashMap<K, V> _cache = LinkedHashMap();
  final int cacheSize;

  MemoryCache({this.cacheSize = 10});

  /// Adds the [value] to the cache under [key].
  ///
  /// If that [key] is already used, updates the value.
  void setValue(K key, V value) {
    final preexisting = _cache.containsKey(key);
    _cache[key] = value;

    if (!preexisting) {
      while (_cache.length > cacheSize) {
        final k = _cache.keys.first;
        _cache.remove(k);
      }
    }
  }

  /// Removes the value from the cache.
  void clear(K key) {
    _cache.remove(key);
  }

  /// Removes all the values from the cache.
  void clearCache() {
    _cache.clear();
  }

  /// Gets the value under [key].
  V? getValue(K key) => _cache[key];

  /// Checks whether the cache has any value under [key].
  bool containsKey(K key) => _cache.containsKey(key);

  /// Returns the number of values saved in this memory cache.
  int get size => _cache.length;

  /// Iterates over all existing keys with values.
  Iterable<K> get keys => _cache.keys;
}
