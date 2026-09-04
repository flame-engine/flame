part of 'component.dart';

/// The per-type query caches of a [ComponentList], created lazily on the
/// first [ComponentList.register] call.
///
/// Each cache holds the subset of the list's elements that are of the
/// registered type, in the same order as the list itself, so that
/// [ComponentList.query] can answer in constant time. The list notifies the
/// store of every structural change ([onAdd], [onRemove], [clear], [resort])
/// to keep the caches up to date.
///
/// Removals are handled lazily, mirroring the tombstones of the backing
/// array: [onRemove] only marks the caches that match the removed component,
/// and the stale entries are dropped by [compact], in a single pass that
/// covers any number of removals at once, before anything can observe them.
/// Searching every matching cache on each removal instead would cost O(n) in
/// the size of the cache, while the removal from the backing array itself is
/// O(1).
class _QueryCacheStore {
  final Map<Type, _QueryCache<Component>> _caches = {};

  /// Whether any of the caches may still hold entries for components that
  /// have since been removed from the list.
  bool _hasStaleEntries = false;

  /// Whether type [C] has been registered as a queryable type.
  bool isRegistered<C extends Component>() => _caches.containsKey(C);

  /// Builds a cache for type [C] from the current contents of [list]. Does
  /// nothing if the type is already registered.
  void register<C extends Component>(ComponentList list) {
    if (_caches.containsKey(C)) {
      return;
    }
    final data = <C>[];
    for (final element in list._elements) {
      if (element is C) {
        data.add(element);
      }
    }
    _caches[C] = _QueryCache<C>(data);
  }

  /// The cached elements of type [C], freshly compacted, or `null` if the
  /// type is not registered.
  Iterable<C>? find<C>(ComponentList list) {
    final cache = _caches[C];
    if (cache == null) {
      return null;
    }
    compact(list);
    // The cached list itself is returned, but typed as an Iterable to prevent
    // accidental modification of the cache from the outside.
    return cache.data as Iterable<C>;
  }

  /// Inserts [component] into every cache whose type matches it.
  void onAdd(Component component) {
    for (final cache in _caches.values) {
      if (cache.check(component)) {
        cache.insertSorted(component);
      }
    }
  }

  /// Marks every cache whose type matches [component] as holding a stale
  /// entry; the entry itself is dropped by the next [compact].
  void onRemove(Component component) {
    for (final cache in _caches.values) {
      if (cache.check(component)) {
        cache.hasStaleEntries = true;
        _hasStaleEntries = true;
      }
    }
  }

  /// Empties every cache, dropping any stale entries with the live ones.
  void clear() {
    for (final cache in _caches.values) {
      cache
        ..data.clear()
        ..hasStaleEntries = false;
    }
    _hasStaleEntries = false;
  }

  /// Restores the order of every cache after the list has been re-sorted (at
  /// which point every element's index is up to date again).
  void resort() {
    for (final cache in _caches.values) {
      cache.resort();
    }
  }

  /// Drops the entries of removed components from the caches, if any removal
  /// has left some behind.
  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  void compact(ComponentList list) {
    if (!_hasStaleEntries) {
      return;
    }
    _hasStaleEntries = false;
    for (final cache in _caches.values) {
      cache.compact(list);
    }
  }
}

/// A cached, always up-to-date result of `query<C>()`: the subset of the
/// elements that are of type [C], in the same order as the main list.
class _QueryCache<C extends Component> {
  _QueryCache(this.data);

  final List<C> data;

  /// Whether [data] may hold entries for components that have since been
  /// removed from the list; see [_QueryCacheStore._hasStaleEntries].
  bool hasStaleEntries = false;

  bool check(Component component) => component is C;

  /// Drops the entries that are no longer in [list], in a single pass that
  /// preserves the order of the remaining ones.
  void compact(ComponentList list) {
    if (!hasStaleEntries) {
      return;
    }
    hasStaleEntries = false;
    final data = this.data;
    var write = 0;
    for (var read = 0; read < data.length; read++) {
      final element = data[read];
      if (identical(element._containerList, list)) {
        if (write != read) {
          data[write] = element;
        }
        write++;
      }
    }
    data.length = write;
  }

  /// Inserts [component] into [data], keeping it ordered consistently with
  /// the main backing list (which orders by priority).
  void insertSorted(Component component) {
    final list = data;
    final index = component._containerIndex;
    if (list.isEmpty || list.last._containerIndex < index) {
      list.add(component as C);
      return;
    }
    final insertionIndex = _partitionPoint(
      list,
      (element) => element._containerIndex < index,
    );
    list.insert(insertionIndex, component as C);
  }

  /// Re-sorts the cache after the main list has been re-sorted (at which
  /// point every element's index is up to date again).
  void resort() {
    data.sort((a, b) => a._containerIndex - b._containerIndex);
  }
}
