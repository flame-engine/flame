/// Used for caching calculated values, the cache is determined to be valid by
/// comparing a list of values that can be of any type and is compared to the
/// values that was last used when the cache was updated.
class ValueCache<T> {
  T? value;

  List<dynamic> _lastValidCacheValues = <dynamic>[];

  ValueCache();

  bool isCacheValid<F>(List<F> validCacheValues) {
    if (value == null) {
      return false;
    }
    for (var i = 0; i < _lastValidCacheValues.length; ++i) {
      if (_lastValidCacheValues[i] != validCacheValues[i]) {
        return false;
      }
    }
    return true;
  }

  T updateCache<F>(T value, List<F> validCacheValues) {
    this.value = value;
    _lastValidCacheValues = validCacheValues;
    return value;
  }
}
