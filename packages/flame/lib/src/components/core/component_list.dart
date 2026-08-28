part of 'component.dart';

/// A fast, ordered container for a [Component]'s children.
///
/// The children are stored in a single flat [List], sorted by
/// [Component.priority] (or by a custom comparator, see
/// [Component.createComponentList]); components that compare equal keep the
/// order in which they were added. Each component also stores the list it is
/// in and its index within that list, which is what makes membership checks
/// and removals constant time.
///
/// Performance characteristics:
///  - iteration: O(n) over the backing list, without any allocations on the
///    internal engine paths;
///  - [add]: O(1) when the component sorts at or after the current last
///    element, which is the common case since children are usually added with
///    the default priority or in non-decreasing priority order, and O(n) when
///    a lower priority forces a mid-list insertion. Additions made through
///    [Component.add] on a mounted parent are deferred to the lifecycle queue
///    and applied in a batch at the start of the next tick, but each one is
///    still an individual insertion into this list;
///  - [remove] and [contains]: O(1), using the index that is stored on the
///    component itself;
///  - [rebalance] (after priority changes): O(n) when the list turns out to
///    still be sorted, otherwise O(n log n) with a stable sort.
///
/// A removal does not shift the backing list, it leaves a `null` "tombstone"
/// in place. Tombstones are invisible to iteration and are compacted away at
/// the start of the next update tick, or earlier if they grow to dominate the
/// list.
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
  ComponentList({this.strictMode = false, this.comparator});

  /// Whether calling [query] for an unregistered type throws an error
  /// (`true`), or transparently registers the type on first use (`false`).
  ///
  /// Registering a type builds its query cache with one pass over the current
  /// elements. Strict mode forces that pass to happen at a moment of your
  /// choosing (typically `onLoad`) instead of on the first query, which could
  /// otherwise cause a frame drop in the middle of gameplay.
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
  /// (unless the whole list empties out, or a structural operation needs a
  /// dense list anyway).
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
  Iterator<Component> get iterator => _ComponentListIterator(this);

  /// The elements of this list in reverse order.
  ///
  /// The returned iterable is a lazy view: it costs nothing to create and
  /// always reflects the current contents.
  Iterable<Component> get reversed => _ReversedComponentListView(this);

  @override
  bool contains(Object? element) {
    return element is Component && identical(element._containerList, this);
  }

  @override
  Component get first {
    for (final element in _elements) {
      if (element != null) {
        return element;
      }
    }
    throw StateError('No element');
  }

  @override
  Component get last {
    for (final element in _elements.reversed) {
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
    for (final element in elements) {
      if (element != null && live++ == index) {
        return element;
      }
    }
    throw IndexError.withLength(index, _length, indexable: this);
  }

  @override
  void forEach(void Function(Component element) action) {
    for (final element in _elements) {
      if (element != null) {
        action(element);
      }
    }
  }

  /// Adds [component] to this list, keeping the priority ordering; returns
  /// whether the component was added (`false` if it already was in the list).
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
      // The list contains only tombstones; reset it.
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
    // Removes all tombstones, which makes the `element!` accesses safe.
    _compact();
    final elements = _elements;
    final index = _partitionPoint(
      elements,
      (element) => _compareOrder(element!, component) <= 0,
    );
    elements.insert(index, component);
    component._containerIndex = index;
    for (var i = index + 1; i < elements.length; i++) {
      elements[i]!._containerIndex = i;
    }
    _shiftCount++;
  }

  /// Removes [component] from this list; returns whether it was present.
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

  /// Removes all elements from this list.
  ///
  /// This is internal machinery: clearing this list does not make the
  /// components go through the component lifecycle. Use [Component.removeAll]
  /// instead.
  @internal
  void clear() {
    final elements = _elements;
    for (final element in elements) {
      if (element != null) {
        element._containerList = null;
        element._containerIndex = -1;
      }
    }
    elements.clear();
    _length = 0;
    _tombstones = 0;
    _shiftCount++;
    _queries?.forEach((_, cache) => cache.data.clear());
  }

  /// Restores the priority ordering after one or more elements have changed
  /// their [Component.priority].
  ///
  /// This is invoked automatically, at most once per parent per game tick,
  /// when priorities of mounted components change. The sort is stable:
  /// components with equal priority keep their relative order.
  void rebalance() {
    // Removes all tombstones, which makes the `element!` accesses safe.
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
    // List.sort is not stable, and the stable alternatives (such as mergeSort
    // from package:collection) allocate a scratch buffer on every call.
    // Breaking ties by the pre-sort index costs nothing extra, since the index
    // is maintained on every element anyway, and makes the built-in sort
    // behave as a stable one.
    elements.sort((a, b) {
      final byOrder = _compareOrder(a!, b!);
      return byOrder != 0 ? byOrder : a._containerIndex - b._containerIndex;
    });
    for (var i = 0; i < elements.length; i++) {
      elements[i]!._containerIndex = i;
    }
    _queries?.forEach((_, cache) => cache.resort());
  }

  /// Rewrites the backing list without its tombstones, restoring exact
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
  /// a non-empty list costs one pass over the existing elements, so it is
  /// recommended to register the desired types as early as possible.
  void register<C extends Component>() {
    final queries = _queries ??= {};
    if (queries.containsKey(C)) {
      return;
    }
    final data = <C>[];
    for (final element in _elements) {
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
        throw StateError(
          'Cannot query unregistered type $C. This list is in strict mode, '
          'which requires register<$C>() to be called before the first '
          'query<$C>(), so that the query cache is built at a controlled '
          'moment (typically in onLoad) instead of in the middle of a frame. '
          'To register types lazily instead, create the list with '
          'strictMode: false.',
        );
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

/// The index of the first element of [list] for which [isBefore] is false, or
/// `list.length` if there is no such element.
///
/// [list] must be partitioned with respect to [isBefore]: all elements for
/// which it is true come before all elements for which it is false. This is
/// the insertion point that keeps a sorted list sorted.
int _partitionPoint<T>(List<T> list, bool Function(T element) isBefore) {
  var low = 0;
  var high = list.length;
  while (low < high) {
    final middle = (low + high) ~/ 2;
    if (isBefore(list[middle])) {
      low = middle + 1;
    } else {
      high = middle;
    }
  }
  return low;
}

class _ComponentListIterator implements Iterator<Component> {
  _ComponentListIterator(this._list) : _shiftCount = _list._shiftCount;

  final ComponentList _list;
  final int _shiftCount;
  int _index = -1;
  Component? _current;

  @override
  Component get current => _current!;

  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  @override
  bool moveNext() {
    final list = _list;
    if (list._shiftCount != _shiftCount) {
      throw ConcurrentModificationError(list);
    }
    final elements = list._elements;
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
  _ReversedComponentListView(this._list);

  final ComponentList _list;

  @override
  int get length => _list._length;

  @override
  bool get isEmpty => _list._length == 0;

  @override
  bool get isNotEmpty => _list._length != 0;

  @override
  Iterator<Component> get iterator => _ReversedComponentListIterator(_list);
}

class _ReversedComponentListIterator implements Iterator<Component> {
  _ReversedComponentListIterator(ComponentList list)
    : _list = list,
      _shiftCount = list._shiftCount,
      _index = list._elements.length;

  final ComponentList _list;
  final int _shiftCount;
  int _index;
  Component? _current;

  @override
  Component get current => _current!;

  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  @override
  bool moveNext() {
    final list = _list;
    if (list._shiftCount != _shiftCount) {
      throw ConcurrentModificationError(list);
    }
    final elements = list._elements;
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
/// elements that are of type [C], in the same order as the main list.
class _QueryCache<C extends Component> {
  _QueryCache(this.data);

  final List<C> data;

  bool check(Component component) => component is C;

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
