
/// Simple class to cache values on the cache
///
class MemoryCache <K, V> {
  final Map<K, V> _cache = {};
  final List<K> _addedOrder = [];
  final int cacheSize;

  MemoryCache({ this.cacheSize = 10 });

  void setValue(K key, V value) {
    if (!_cache.containsKey(key)) {
      _cache[key] = value;
      _addedOrder.add(key);

      while (_addedOrder.length > cacheSize) {
        final k = _addedOrder.removeAt(0);
        _cache.remove(k);
      }
    }
  }

  V getValue(K key) => _cache[key];

  bool containsKey(K key) => _cache.containsKey(key);

  int get size => _cache.length;
}
