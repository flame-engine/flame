part of 'component.dart';

/// A fast, ordered container for a [Component]'s children.
///
/// Variant D (proposed in review): a `SplayTreeMap<(priority, insertOrder),
/// Component>`. Compared to the old `OrderedSet`, the per-priority
/// `Set<Component>` buckets are gone: each component maps directly from its
/// composite key, so no set allocations or hashing happen on add/remove, and
/// duplicates are impossible by construction. Components with equal priority
/// keep the order in which they were added via the monotonically increasing
/// insert-order half of the key.
///
/// Performance characteristics:
///  - iteration: O(n) in-order tree walk (amortized), one iterator per pass;
///  - [add] and [remove]: O(log n) amortized, one key record per operation;
///  - [rebalance] (after priority changes): O(k log n) for k moved
///    components, no global sort;
///  - reversed iteration: backwards key stepping, amortized O(n) per pass.
class ComponentSet extends Iterable<Component> {
  ComponentSet({bool? strictMode})
    : strictMode = strictMode ?? Component.strictQueryMode;

  /// Whether calling [query] for an unregistered type throws an error
  /// (`true`), or transparently registers the type on first use (`false`).
  final bool strictMode;

  /// The backing store, ordered by `(priority, insertOrder)`.
  final SplayTreeMap<(int, int), Component> _map = SplayTreeMap(_compareKeys);

  static int _compareKeys((int, int) a, (int, int) b) {
    final byPriority = a.$1.compareTo(b.$1);
    return byPriority != 0 ? byPriority : a.$2.compareTo(b.$2);
  }

  /// The insert-order half of the next key; monotonically increasing so that
  /// equal priorities keep insertion order.
  int _nextInsertOrder = 0;

  /// The per-type query caches, created by [register].
  Map<Type, _QueryCache<Component>>? _queries;

  @override
  int get length => _map.length;

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  Iterator<Component> get iterator => _map.values.iterator;

  /// The elements of this set in reverse order.
  Iterable<Component> reversed() => _ReversedComponentSetView(this);

  @override
  bool contains(Object? element) {
    return element is Component && identical(element._containerSet, this);
  }

  @override
  Component get first {
    final firstKey = _map.firstKey();
    if (firstKey == null) {
      throw StateError('No element');
    }
    return _map[firstKey]!;
  }

  @override
  Component get last {
    final lastKey = _map.lastKey();
    if (lastKey == null) {
      throw StateError('No element');
    }
    return _map[lastKey]!;
  }

  /// Adds [component] to this set, keeping the priority ordering; returns
  /// whether the component was added (`false` if it already was in the set).
  ///
  /// This is internal machinery: adding a component here does not make it go
  /// through the component lifecycle. Use [Component.add] instead.
  @internal
  bool add(Component component) {
    if (identical(component._containerSet, this)) {
      return false;
    }
    assert(
      component._containerSet == null,
      'A component cannot be contained by two children containers at once',
    );
    final key = (component._priority, _nextInsertOrder++);
    component._keyPriority = key.$1;
    component._containerIndex = key.$2;
    component._containerSet = this;
    _map[key] = component;
    final queries = _queries;
    if (queries != null) {
      for (final cache in queries.values) {
        if (cache.check(component)) {
          cache.data.add(component);
        }
      }
    }
    return true;
  }

  /// Removes [component] from this set; returns whether it was present.
  ///
  /// This is internal machinery: removing a component here does not make it
  /// go through the component lifecycle. Use [Component.remove] instead.
  @internal
  bool remove(Component component) {
    if (!identical(component._containerSet, this)) {
      return false;
    }
    final removed = _map.remove(
      (component._keyPriority, component._containerIndex),
    );
    assert(identical(removed, component));
    component._containerSet = null;
    component._containerIndex = -1;
    final queries = _queries;
    if (queries != null) {
      for (final cache in queries.values) {
        if (cache.check(component)) {
          cache.data.remove(component);
        }
      }
    }
    return true;
  }

  /// Removes all elements from this set.
  ///
  /// This is internal machinery: clearing this set does not make the
  /// components go through the component lifecycle. Use [Component.removeAll]
  /// instead.
  @internal
  void clear() {
    for (final component in _map.values) {
      component._containerSet = null;
      component._containerIndex = -1;
    }
    _map.clear();
    _queries?.forEach((_, cache) => cache.data.clear());
  }

  /// Restores the priority ordering after one or more elements have changed
  /// their [Component.priority].
  ///
  /// Each component whose priority no longer matches its key is re-keyed:
  /// an O(log n) remove plus insert, instead of a global sort.
  void rebalance() {
    List<Component>? movers;
    for (final component in _map.values) {
      if (component._priority != component._keyPriority) {
        (movers ??= []).add(component);
      }
    }
    if (movers == null) {
      return;
    }
    for (var i = 0; i < movers.length; i++) {
      final component = movers[i];
      _map.remove((component._keyPriority, component._containerIndex));
      final key = (component._priority, _nextInsertOrder++);
      component._keyPriority = key.$1;
      component._containerIndex = key.$2;
      _map[key] = component;
    }
  }

  /// Whether type [C] has been registered as a queryable type.
  bool isRegistered<C extends Component>() {
    return _queries?.containsKey(C) ?? false;
  }

  /// Registers [C] as a queryable type, so that [query] can answer in O(1).
  void register<C extends Component>() {
    final queries = _queries ??= {};
    if (queries.containsKey(C)) {
      return;
    }
    final data = <C>[];
    for (final component in _map.values) {
      if (component is C) {
        data.add(component);
      }
    }
    queries[C] = _QueryCache<C>(data);
  }

  /// All elements of type [C] in O(1).
  Iterable<C> query<C extends Component>() {
    final cache = _queries?[C];
    if (cache == null) {
      if (strictMode) {
        throw StateError('Cannot query unregistered query $C');
      }
      register<C>();
      return query<C>();
    }
    return cache.data as Iterable<C>;
  }

  @override
  Iterable<C> whereType<C>() {
    final cache = _queries?[C];
    if (cache != null) {
      return cache.data as Iterable<C>;
    }
    return super.whereType<C>();
  }
}

class _ReversedComponentSetView extends Iterable<Component> {
  _ReversedComponentSetView(this._set);

  final ComponentSet _set;

  @override
  int get length => _set.length;

  @override
  bool get isEmpty => _set.isEmpty;

  @override
  bool get isNotEmpty => _set.isNotEmpty;

  @override
  Iterator<Component> get iterator => _ReversedComponentSetIterator(_set._map);
}

class _ReversedComponentSetIterator implements Iterator<Component> {
  _ReversedComponentSetIterator(this._map) : _nextKey = _map.lastKey();

  final SplayTreeMap<(int, int), Component> _map;
  (int, int)? _nextKey;
  Component? _current;

  @override
  Component get current => _current!;

  @override
  bool moveNext() {
    final key = _nextKey;
    if (key == null) {
      _current = null;
      return false;
    }
    _current = _map[key];
    _nextKey = _map.lastKeyBefore(key);
    return true;
  }
}

/// A cached, always up-to-date result of `query<C>()`.
class _QueryCache<C extends Component> {
  _QueryCache(this.data);

  final List<C> data;

  bool check(Component component) => component is C;
}
