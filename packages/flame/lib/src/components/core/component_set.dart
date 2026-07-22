part of 'component.dart';

/// A fast, ordered container for a [Component]'s children.
///
/// Variant C: priority-bucketed dense arrays. The container keeps a list of
/// buckets, one per distinct [Component.priority] value, sorted by priority;
/// each bucket is a dense array of the components with that priority, in
/// insertion order. Every component stores an intrusive reference to its
/// bucket and its slot index within it.
///
/// Performance characteristics:
///  - iteration: O(n) over the bucket arrays in priority order;
///  - [add]: O(1) append into the right bucket (plus O(log b) bucket lookup,
///    where b is the number of distinct priorities);
///  - [remove] and [contains]: O(1) via the intrusive references;
///  - [rebalance]: O(n) scan; each moved component pays a bucket move
///    instead of participating in a global sort.
///
/// A removal leaves a `null` tombstone in its bucket; tombstones are
/// invisible to iteration and are compacted at the next update tick, or when
/// they grow to dominate their bucket.
class ComponentSet extends Iterable<Component> {
  ComponentSet({bool? strictMode})
    : strictMode = strictMode ?? Component.strictQueryMode;

  /// Whether calling [query] for an unregistered type throws an error
  /// (`true`), or transparently registers the type on first use (`false`).
  final bool strictMode;

  /// The buckets, sorted by their unique [_PriorityBucket.priority].
  final List<_PriorityBucket> _buckets = [];

  /// The number of live elements across all buckets.
  int _length = 0;

  /// Incremented whenever existing elements change their position (bucket
  /// list shifts, bucket compaction, reordering). Iterators use this to
  /// detect concurrent structural modification.
  int _shiftCount = 0;

  /// Compaction of a bucket is deferred until this many tombstones have
  /// accumulated in it (unless it empties out entirely).
  static const int _tombstoneCompactionThreshold = 16;

  /// The per-type query caches, created by [register].
  Map<Type, _QueryCache<Component>>? _queries;

  @override
  int get length => _length;

  @override
  bool get isEmpty => _length == 0;

  @override
  bool get isNotEmpty => _length != 0;

  @override
  Iterator<Component> get iterator => _ComponentSetIterator(this);

  /// The elements of this set in reverse order.
  Iterable<Component> reversed() => _ReversedComponentSetView(this);

  @override
  bool contains(Object? element) {
    return element is Component && identical(element._containerSet, this);
  }

  @override
  Component get first {
    final buckets = _buckets;
    for (var b = 0; b < buckets.length; b++) {
      final members = buckets[b].members;
      for (var i = 0; i < members.length; i++) {
        final element = members[i];
        if (element != null) {
          return element;
        }
      }
    }
    throw StateError('No element');
  }

  @override
  Component get last {
    final buckets = _buckets;
    for (var b = buckets.length - 1; b >= 0; b--) {
      final members = buckets[b].members;
      for (var i = members.length - 1; i >= 0; i--) {
        final element = members[i];
        if (element != null) {
          return element;
        }
      }
    }
    throw StateError('No element');
  }

  @override
  Component elementAt(int index) {
    RangeError.checkNotNegative(index, 'index');
    var live = 0;
    final buckets = _buckets;
    for (var b = 0; b < buckets.length; b++) {
      final members = buckets[b].members;
      for (var i = 0; i < members.length; i++) {
        final element = members[i];
        if (element != null && live++ == index) {
          return element;
        }
      }
    }
    throw IndexError.withLength(index, _length, indexable: this);
  }

  @override
  void forEach(void Function(Component element) action) {
    final buckets = _buckets;
    for (var b = 0; b < buckets.length; b++) {
      final members = buckets[b].members;
      for (var i = 0; i < members.length; i++) {
        final element = members[i];
        if (element != null) {
          action(element);
        }
      }
    }
  }

  /// Binary search for the bucket with exactly [priority]; returns its index
  /// or, if absent, `-(insertionPoint + 1)`.
  int _bucketIndexOf(int priority) {
    var lo = 0;
    var hi = _buckets.length;
    while (lo < hi) {
      final mid = (lo + hi) >>> 1;
      final midPriority = _buckets[mid].priority;
      if (midPriority < priority) {
        lo = mid + 1;
      } else if (midPriority > priority) {
        hi = mid;
      } else {
        return mid;
      }
    }
    return -(lo + 1);
  }

  _PriorityBucket _bucketFor(int priority) {
    final buckets = _buckets;
    // Fast path: the common case is appending at (or after) the end.
    if (buckets.isEmpty || buckets.last.priority < priority) {
      final bucket = _PriorityBucket(priority);
      buckets.add(bucket);
      return bucket;
    }
    if (buckets.last.priority == priority) {
      return buckets.last;
    }
    final index = _bucketIndexOf(priority);
    if (index >= 0) {
      return buckets[index];
    }
    final bucket = _PriorityBucket(priority);
    buckets.insert(-index - 1, bucket);
    _shiftCount++;
    return bucket;
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
    final bucket = _bucketFor(component._priority);
    component._containerIndex = bucket.members.length;
    component._bucket = bucket;
    component._containerSet = this;
    bucket.members.add(component);
    bucket.live++;
    _length++;
    final queries = _queries;
    if (queries != null) {
      for (final cache in queries.values) {
        if (cache.check(component)) {
          cache.insertSorted(component);
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
    final bucket = component._bucket!;
    final index = component._containerIndex;
    assert(identical(bucket.members[index], component));
    bucket.members[index] = null;
    bucket.live--;
    bucket.tombstones++;
    component._containerSet = null;
    component._bucket = null;
    component._containerIndex = -1;
    _length--;
    final queries = _queries;
    if (queries != null) {
      for (final cache in queries.values) {
        if (cache.check(component)) {
          cache.data.remove(component);
        }
      }
    }
    if (bucket.live == 0) {
      final bucketIndex = _bucketIndexOf(bucket.priority);
      assert(bucketIndex >= 0);
      _buckets.removeAt(bucketIndex);
      _shiftCount++;
    } else if (bucket.tombstones >= _tombstoneCompactionThreshold &&
        bucket.tombstones * 2 >= bucket.members.length) {
      bucket.compact();
      _shiftCount++;
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
    final buckets = _buckets;
    for (var b = 0; b < buckets.length; b++) {
      final members = buckets[b].members;
      for (var i = 0; i < members.length; i++) {
        final element = members[i];
        if (element != null) {
          element._containerSet = null;
          element._bucket = null;
          element._containerIndex = -1;
        }
      }
    }
    buckets.clear();
    _length = 0;
    _shiftCount++;
    _queries?.forEach((_, cache) => cache.data.clear());
  }

  /// Compacts the tombstones out of every bucket. Called by the engine at
  /// the start of each update pass, when no iteration can be in progress.
  void _compact() {
    final buckets = _buckets;
    var compacted = false;
    for (var b = 0; b < buckets.length; b++) {
      final bucket = buckets[b];
      if (bucket.tombstones > 0) {
        bucket.compact();
        compacted = true;
      }
    }
    if (compacted) {
      _shiftCount++;
    }
  }

  /// Restores the priority ordering after one or more elements have changed
  /// their [Component.priority].
  ///
  /// This is invoked automatically, at most once per parent per game tick,
  /// when priorities of mounted components change. Components whose priority
  /// changed are moved to the bucket matching their new priority, appended
  /// after that bucket's existing members in their previous relative order.
  void rebalance() {
    _compact();
    // Collect the components that no longer match their bucket's priority,
    // in the current iteration order.
    List<Component>? movers;
    final buckets = _buckets;
    for (var b = 0; b < buckets.length; b++) {
      final bucket = buckets[b];
      final members = bucket.members;
      for (var i = 0; i < members.length; i++) {
        final element = members[i];
        if (element != null && element._priority != bucket.priority) {
          (movers ??= []).add(element);
        }
      }
    }
    if (movers == null) {
      return;
    }
    _shiftCount++;
    for (var i = 0; i < movers.length; i++) {
      final component = movers[i];
      final bucket = component._bucket!;
      bucket.members[component._containerIndex] = null;
      bucket.live--;
      bucket.tombstones++;
    }
    // Drop emptied buckets and compact the rest before re-inserting, so that
    // bucket lookups and new indices are exact.
    buckets.removeWhere((bucket) => bucket.live == 0);
    for (var b = 0; b < buckets.length; b++) {
      if (buckets[b].tombstones > 0) {
        buckets[b].compact();
      }
    }
    for (var i = 0; i < movers.length; i++) {
      final component = movers[i];
      final bucket = _bucketFor(component._priority);
      component._containerIndex = bucket.members.length;
      component._bucket = bucket;
      bucket.members.add(component);
      bucket.live++;
    }
    _queries?.forEach((_, cache) => cache.resort());
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
    final buckets = _buckets;
    for (var b = 0; b < buckets.length; b++) {
      final members = buckets[b].members;
      for (var i = 0; i < members.length; i++) {
        final element = members[i];
        if (element is C) {
          data.add(element);
        }
      }
    }
    queries[C] = _QueryCache<C>(data);
  }

  /// All elements of type [C], in priority order, in O(1).
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

/// A single priority level: the components with that priority, in insertion
/// order, with `null` tombstones left by removals.
class _PriorityBucket {
  _PriorityBucket(this.priority);

  final int priority;
  final List<Component?> members = [];
  int live = 0;
  int tombstones = 0;

  void compact() {
    var write = 0;
    for (var read = 0; read < members.length; read++) {
      final element = members[read];
      if (element != null) {
        if (write != read) {
          members[write] = element;
          element._containerIndex = write;
        }
        write++;
      }
    }
    members.length = write;
    tombstones = 0;
  }
}

class _ComponentSetIterator implements Iterator<Component> {
  _ComponentSetIterator(this._set) : _shiftCount = _set._shiftCount;

  final ComponentSet _set;
  final int _shiftCount;
  int _bucketIndex = 0;
  int _memberIndex = -1;
  Component? _current;

  @override
  Component get current => _current!;

  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  @override
  bool moveNext() {
    final set = _set;
    if (set._shiftCount != _shiftCount) {
      throw ConcurrentModificationError(set);
    }
    final buckets = set._buckets;
    var memberIndex = _memberIndex;
    for (var b = _bucketIndex; b < buckets.length; b++) {
      final members = buckets[b].members;
      for (var i = memberIndex + 1; i < members.length; i++) {
        final element = members[i];
        if (element != null) {
          _bucketIndex = b;
          _memberIndex = i;
          _current = element;
          return true;
        }
      }
      memberIndex = -1;
    }
    _bucketIndex = buckets.length;
    _memberIndex = -1;
    _current = null;
    return false;
  }
}

class _ReversedComponentSetView extends Iterable<Component> {
  _ReversedComponentSetView(this._set);

  final ComponentSet _set;

  @override
  int get length => _set._length;

  @override
  bool get isEmpty => _set._length == 0;

  @override
  bool get isNotEmpty => _set._length != 0;

  @override
  Iterator<Component> get iterator => _ReversedComponentSetIterator(_set);
}

class _ReversedComponentSetIterator implements Iterator<Component> {
  _ReversedComponentSetIterator(ComponentSet set)
    : _set = set,
      _shiftCount = set._shiftCount,
      _bucketIndex = set._buckets.length - 1,
      _memberIndex = set._buckets.isEmpty
          ? 0
          : set._buckets.last.members.length;

  final ComponentSet _set;
  final int _shiftCount;
  int _bucketIndex;
  int _memberIndex;
  Component? _current;

  @override
  Component get current => _current!;

  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  @override
  bool moveNext() {
    final set = _set;
    if (set._shiftCount != _shiftCount) {
      throw ConcurrentModificationError(set);
    }
    final buckets = set._buckets;
    var memberIndex = _memberIndex;
    for (var b = _bucketIndex; b >= 0; b--) {
      final members = buckets[b].members;
      for (var i = memberIndex - 1; i >= 0; i--) {
        final element = members[i];
        if (element != null) {
          _bucketIndex = b;
          _memberIndex = i;
          _current = element;
          return true;
        }
      }
      memberIndex = b > 0 ? buckets[b - 1].members.length : 0;
    }
    _bucketIndex = -1;
    _memberIndex = 0;
    _current = null;
    return false;
  }
}

/// A cached, always up-to-date result of `query<C>()`: the subset of the
/// elements that are of type [C], ordered consistently with the main
/// iteration order.
class _QueryCache<C extends Component> {
  _QueryCache(this.data);

  final List<C> data;

  bool check(Component component) => component is C;

  static int _compareOrder(Component a, Component b) {
    final byPriority = a._bucket!.priority.compareTo(b._bucket!.priority);
    return byPriority != 0 ? byPriority : a._containerIndex - b._containerIndex;
  }

  /// Inserts [component] into [data], keeping the cache ordered consistently
  /// with the main iteration order.
  void insertSorted(Component component) {
    final list = data;
    if (list.isEmpty || _compareOrder(list.last, component) < 0) {
      list.add(component as C);
      return;
    }
    var lo = 0;
    var hi = list.length;
    while (lo < hi) {
      final mid = (lo + hi) >>> 1;
      if (_compareOrder(list[mid], component) < 0) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    list.insert(lo, component as C);
  }

  /// Re-sorts the cache after the buckets have been reorganized.
  void resort() {
    data.sort(_compareOrder);
  }
}
