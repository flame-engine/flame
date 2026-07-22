part of 'component.dart';

/// A fast, ordered container for a [Component]'s children.
///
/// The children are stored in a single flat [List], sorted by
/// [Component.priority] (or by a custom comparator, see
/// [Component.createComponentList]); components that compare equal keep the
/// order in which they were added. This is the same ordering that the old
/// `OrderedSet`-based container provided, but backed by a contiguous array
/// instead of a splay tree of hash sets, which makes iteration, additions,
/// removals and reorders significantly faster and allocation-free.
///
/// Performance characteristics:
///  - iteration: O(n) over a contiguous array, without any allocations on the
///    internal engine paths;
///  - [add]: O(1) when the component sorts at or after the end, which is the
///    common case, and O(n) for a mid-list insertion;
///  - [remove] and [contains]: O(1), using the slot index that is stored on
///    the component itself;
///  - [rebalance] (after priority changes): O(n) when the list turns out to
///    still be sorted, otherwise O(n log n) with a stable sort.
///
/// A removal does not shift the array, it leaves a `null` "tombstone" in
/// place. Tombstones are invisible to iteration and are compacted away at the
/// start of the next update tick, or earlier if they grow to dominate the
/// array.
///
/// Mutating the container while iterating it is allowed in the ways that the
/// component lifecycle needs: removals take effect immediately (the removed
/// component is simply not visited), and additions at the end may or may not
/// be visited by an ongoing iteration. Operations that shift the positions of
/// existing elements (a mid-list insertion, [rebalance], or tombstone
/// compaction) invalidate live iterators, which will then throw a
/// [ConcurrentModificationError].
///
/// The contents of this container are managed by the [Component] lifecycle:
/// use [Component.add], [Component.remove] and their related methods to
/// modify which components are in it.
class ComponentList extends Iterable<Component> {
  ComponentList({bool? strictMode, this.comparator})
    : strictMode = strictMode ?? Component.strictQueryMode;

  /// Whether calling [query] for an unregistered type throws an error
  /// (`true`), or transparently registers the type on first use (`false`).
  final bool strictMode;

  /// An optional custom ordering, replacing the default ordering by
  /// [Component.priority]. Supply one via [Component.createComponentList].
  ///
  /// The ordering is stable in both cases: elements that compare equal keep
  /// their insertion order. If the values that the comparator reads change
  /// after insertion, call [Component.rebalanceChildren] to restore the
  /// ordering (priority changes on mounted components do this automatically).
  final Comparator<Component>? comparator;

  /// The relative order of [a] and [b]: by the custom [comparator] if one
  /// was supplied, otherwise by [Component.priority].
  int _compareOrder(Component a, Component b) {
    final comparator = this.comparator;
    if (comparator == null) {
      final ap = a._priority;
      final bp = b._priority;
      return ap < bp
          ? -1
          : ap > bp
          ? 1
          : 0;
    }
    return comparator(a, b);
  }

  /// The backing store; `null` entries are tombstones left by removals.
  final List<Component?> _elements = [];

  /// The number of live (non-tombstone) elements.
  int _length = 0;

  /// The number of tombstones currently present in [_elements].
  int _tombstones = 0;

  /// Incremented whenever existing elements change their position within
  /// [_elements] (mid-list insertion, sorting, or compaction). Iterators use
  /// this to detect concurrent structural modification.
  int _shiftCount = 0;

  /// Compaction is deferred until this many tombstones have accumulated
  /// (unless the whole set empties out, or a structural operation needs a
  /// dense array anyway).
  static const int _tombstoneCompactionThreshold = 16;

  /// The per-type query caches, created by [register].
  Map<Type, _QueryCache<Component>>? _queries;

  /// A monotonically increasing counter, bumped on every membership or order
  /// change of any [ComponentList] (adds, removes, clears, reorders). The
  /// root's flattened update list compares against this to know when it must
  /// be rebuilt. Note that this is bumped by structural changes anywhere,
  /// including in other games or detached trees, so a bump means "possibly
  /// changed", never the reverse.
  @internal
  static int structureVersion = 0;

  @override
  int get length => _length;

  @override
  bool get isEmpty => _length == 0;

  @override
  bool get isNotEmpty => _length != 0;

  @override
  Iterator<Component> get iterator => _ComponentListIterator(this);

  /// The elements of this set in reverse order.
  ///
  /// Unlike the rest of the [Iterable] interface, this is a method and not a
  /// getter, for historical reasons. The returned iterable is a lazy view: it
  /// costs nothing to create and always reflects the current contents.
  Iterable<Component> reversed() => _ReversedComponentListView(this);

  @override
  bool contains(Object? element) {
    return element is Component && identical(element._containerList, this);
  }

  @override
  Component get first {
    final elements = _elements;
    for (var i = 0; i < elements.length; i++) {
      final element = elements[i];
      if (element != null) {
        return element;
      }
    }
    throw StateError('No element');
  }

  @override
  Component get last {
    final elements = _elements;
    for (var i = elements.length - 1; i >= 0; i--) {
      final element = elements[i];
      if (element != null) {
        return element;
      }
    }
    throw StateError('No element');
  }

  @override
  Component elementAt(int index) {
    RangeError.checkNotNegative(index, 'index');
    final elements = _elements;
    if (_tombstones == 0) {
      if (index >= elements.length) {
        throw IndexError.withLength(index, _length, indexable: this);
      }
      return elements[index]!;
    }
    var live = 0;
    for (var i = 0; i < elements.length; i++) {
      final element = elements[i];
      if (element != null && live++ == index) {
        return element;
      }
    }
    throw IndexError.withLength(index, _length, indexable: this);
  }

  @override
  void forEach(void Function(Component element) action) {
    final elements = _elements;
    for (var i = 0; i < elements.length; i++) {
      final element = elements[i];
      if (element != null) {
        action(element);
      }
    }
  }

  /// Adds [component] to this set, keeping the priority ordering; returns
  /// whether the component was added (`false` if it already was in the set).
  ///
  /// This is internal machinery: adding a component here does not make it go
  /// through the component lifecycle. Use [Component.add] instead.
  @internal
  bool add(Component component) {
    if (identical(component._containerList, this)) {
      return false;
    }
    assert(
      component._containerList == null,
      'A component cannot be contained by two children containers at once',
    );
    final elements = _elements;
    if (_length == 0 && elements.isNotEmpty) {
      // The array contains only tombstones; reset it.
      elements.clear();
      _tombstones = 0;
    }
    var lastIndex = elements.length - 1;
    while (lastIndex >= 0 && elements[lastIndex] == null) {
      lastIndex--;
    }
    if (lastIndex >= 0 && _compareOrder(elements[lastIndex]!, component) > 0) {
      _insertSorted(component);
    } else {
      component._containerIndex = elements.length;
      elements.add(component);
    }
    component._containerList = this;
    _length++;
    structureVersion++;
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

  /// Inserts [component] before all existing elements that sort after it,
  /// and after all elements that sort the same or before it.
  void _insertSorted(Component component) {
    _compact();
    final elements = _elements;
    var lo = 0;
    var hi = elements.length;
    while (lo < hi) {
      final mid = (lo + hi) >>> 1;
      if (_compareOrder(elements[mid]!, component) <= 0) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    elements.insert(lo, component);
    component._containerIndex = lo;
    for (var i = lo + 1; i < elements.length; i++) {
      elements[i]!._containerIndex = i;
    }
    _shiftCount++;
  }

  /// Removes [component] from this set; returns whether it was present.
  ///
  /// This is internal machinery: removing a component here does not make it
  /// go through the component lifecycle. Use [Component.remove] instead.
  @internal
  bool remove(Component component) {
    if (!identical(component._containerList, this)) {
      return false;
    }
    final index = component._containerIndex;
    assert(identical(_elements[index], component));
    _elements[index] = null;
    component._containerList = null;
    component._containerIndex = -1;
    _length--;
    _tombstones++;
    structureVersion++;
    final queries = _queries;
    if (queries != null) {
      for (final cache in queries.values) {
        if (cache.check(component)) {
          cache.data.remove(component);
        }
      }
    }
    if (_length == 0) {
      _elements.clear();
      _tombstones = 0;
    } else if (_tombstones >= _tombstoneCompactionThreshold &&
        _tombstones * 2 >= _elements.length) {
      _compact();
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
    final elements = _elements;
    for (var i = 0; i < elements.length; i++) {
      final element = elements[i];
      if (element != null) {
        element._containerList = null;
        element._containerIndex = -1;
      }
    }
    elements.clear();
    _length = 0;
    _tombstones = 0;
    _shiftCount++;
    structureVersion++;
    _queries?.forEach((_, cache) => cache.data.clear());
  }

  /// Restores the priority ordering after one or more elements have changed
  /// their [Component.priority].
  ///
  /// This is invoked automatically, at most once per parent per game tick,
  /// when priorities of mounted components change. The sort is stable:
  /// components with equal priority keep their relative order.
  void rebalance() {
    _compact();
    final elements = _elements;
    var isSorted = true;
    for (var i = 1; i < elements.length; i++) {
      if (_compareOrder(elements[i - 1]!, elements[i]!) > 0) {
        isSorted = false;
        break;
      }
    }
    if (isSorted) {
      return;
    }
    _shiftCount++;
    structureVersion++;
    // Ties are broken by the pre-sort index, which makes the (unstable)
    // built-in sort behave as a stable sort.
    elements.sort((a, b) {
      final byOrder = _compareOrder(a!, b!);
      return byOrder != 0 ? byOrder : a._containerIndex - b._containerIndex;
    });
    for (var i = 0; i < elements.length; i++) {
      elements[i]!._containerIndex = i;
    }
    _queries?.forEach((_, cache) => cache.resort());
  }

  /// Rewrites the backing array without its tombstones, restoring exact
  /// element indices.
  void _compact() {
    if (_tombstones == 0) {
      return;
    }
    final elements = _elements;
    var write = 0;
    for (var read = 0; read < elements.length; read++) {
      final element = elements[read];
      if (element != null) {
        if (write != read) {
          elements[write] = element;
          element._containerIndex = write;
        }
        write++;
      }
    }
    elements.length = write;
    _tombstones = 0;
    _shiftCount++;
  }

  /// Whether type [C] has been registered as a queryable type.
  bool isRegistered<C extends Component>() {
    return _queries?.containsKey(C) ?? false;
  }

  /// Registers [C] as a queryable type, so that [query] can answer in O(1).
  ///
  /// If the type is already registered this is a no-op. Registering a type on
  /// a non-empty set costs one pass over the existing elements, so it is
  /// recommended to register the desired types as early as possible.
  void register<C extends Component>() {
    final queries = _queries ??= {};
    if (queries.containsKey(C)) {
      return;
    }
    final data = <C>[];
    final elements = _elements;
    for (var i = 0; i < elements.length; i++) {
      final element = elements[i];
      if (element is C) {
        data.add(element);
      }
    }
    queries[C] = _QueryCache<C>(data);
  }

  /// All elements of type [C], in priority order, in O(1).
  ///
  /// The type [C] must have been [register]ed beforehand, unless [strictMode]
  /// is false, in which case the registration happens on the first query.
  Iterable<C> query<C extends Component>() {
    final cache = _queries?[C];
    if (cache == null) {
      if (strictMode) {
        throw StateError('Cannot query unregistered query $C');
      }
      register<C>();
      return query<C>();
    }
    // The cached list itself is returned, but typed as an Iterable to prevent
    // accidental modification of the cache from the outside.
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

class _ComponentListIterator implements Iterator<Component> {
  _ComponentListIterator(this._set) : _shiftCount = _set._shiftCount;

  final ComponentList _set;
  final int _shiftCount;
  int _index = -1;
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
    final elements = set._elements;
    for (var i = _index + 1; i < elements.length; i++) {
      final element = elements[i];
      if (element != null) {
        _index = i;
        _current = element;
        return true;
      }
    }
    _index = elements.length;
    _current = null;
    return false;
  }
}

class _ReversedComponentListView extends Iterable<Component> {
  _ReversedComponentListView(this._set);

  final ComponentList _set;

  @override
  int get length => _set._length;

  @override
  bool get isEmpty => _set._length == 0;

  @override
  bool get isNotEmpty => _set._length != 0;

  @override
  Iterator<Component> get iterator => _ReversedComponentListIterator(_set);
}

class _ReversedComponentListIterator implements Iterator<Component> {
  _ReversedComponentListIterator(ComponentList set)
    : _set = set,
      _shiftCount = set._shiftCount,
      _index = set._elements.length;

  final ComponentList _set;
  final int _shiftCount;
  int _index;
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
    final elements = set._elements;
    for (var i = _index - 1; i >= 0; i--) {
      final element = elements[i];
      if (element != null) {
        _index = i;
        _current = element;
        return true;
      }
    }
    _index = -1;
    _current = null;
    return false;
  }
}

/// A cached, always up-to-date result of `query<C>()`: the subset of the
/// elements that are of type [C], in the same order as the main array.
class _QueryCache<C extends Component> {
  _QueryCache(this.data);

  final List<C> data;

  bool check(Component component) => component is C;

  /// Inserts [component] into [data], keeping it ordered consistently with
  /// the main backing array (which orders by priority).
  void insertSorted(Component component) {
    final list = data;
    final index = component._containerIndex;
    if (list.isEmpty || list.last._containerIndex < index) {
      list.add(component as C);
      return;
    }
    var lo = 0;
    var hi = list.length;
    while (lo < hi) {
      final mid = (lo + hi) >>> 1;
      if (list[mid]._containerIndex < index) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    list.insert(lo, component as C);
  }

  /// Re-sorts the cache after the main array has been re-sorted (at which
  /// point every element's index is up to date again).
  void resort() {
    data.sort((a, b) => a._containerIndex - b._containerIndex);
  }
}
