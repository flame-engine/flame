part of 'component.dart';

/// The ordered container for a [Component]'s [Component.children].
///
/// Components are ordered by [Component.priority], or by the [comparator] if
/// one was supplied through [Component.createComponentList]; components that
/// compare equal keep the order in which they were added. Iterating the list,
/// directly or through [reversed], visits the components in that order.
///
/// The contents are managed by the component lifecycle: use [Component.add],
/// [Component.remove] and their related methods to change which components
/// are in the list. Removing a component while iterating the list is allowed,
/// the removed component is simply no longer visited. Reordering the list
/// while iterating it (through [Component.rebalanceChildren], or by an
/// addition that does not end up at the end of the list) makes live iterators
/// throw a [ConcurrentModificationError].
///
/// Components of a specific type can be retrieved in constant time with
/// [query], once the type has been registered with [register].
class ComponentList extends Iterable<Component> {
  ComponentList({this.strictMode = false, this.comparator});

  /// Whether calling [query] for an unregistered type throws an error
  /// (`true`), or registers the type on first use (`false`).
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
      return a._priority.compareTo(b._priority);
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
  /// [_elements] (middle-list insertion, sorting, or compaction). Iterators use
  /// this to detect concurrent structural modification.
  int _shiftCount = 0;

  /// Compaction is deferred until this many tombstones have accumulated
  /// (unless the whole list empties out, or a structural operation needs a
  /// dense list anyway).
  static const int _tombstoneCompactionThreshold = 16;

  /// The per-type query caches, created by [register].
  _QueryCacheStore? _queries;

  /// A monotonically increasing counter, bumped on every membership or order
  /// change of any [ComponentList] (adds, removes, clears, reorders). The
  /// root's flattened update list compares against this to know when it must
  /// be rebuilt. Note that this is bumped by structural changes anywhere,
  /// including in other games or detached trees, so a bump means "possibly
  /// changed", never the reverse.
  static int _structureVersion = 0;

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
  /// Does not run the component lifecycle; that is done by [Component.add].
  bool _add(Component component) {
    if (contains(component)) {
      return false;
    }
    assert(
      component._containerList == null,
      'A component cannot be contained by two children containers at once',
    );
    // Must happen before [component] is linked to this list: a component that
    // is removed and added back before the caches are compacted would
    // otherwise be seen as a live entry and end up in a cache twice.
    _queries?.compact(this);
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
    _structureVersion++;
    _queries?.onAdd(component);
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
  /// Does not run the component lifecycle; that is done by
  /// [Component.remove].
  bool _remove(Component component) {
    if (!contains(component)) {
      return false;
    }
    final index = component._containerIndex;
    assert(identical(_elements[index], component));
    _elements[index] = null;
    component._containerList = null;
    component._containerIndex = -1;
    _length--;
    _tombstones++;
    _structureVersion++;
    _queries?.onRemove(component);
    if (_length == 0) {
      _elements.clear();
      _tombstones = 0;
      // Nothing is left to hold on to, so drop the stale cache entries right
      // away instead of keeping the removed components alive until the next
      // add or query.
      _queries?.compact(this);
    } else if (_tombstones >= _tombstoneCompactionThreshold &&
        _tombstones * 2 >= _elements.length) {
      _compact();
      _queries?.compact(this);
    }
    return true;
  }

  /// Removes all elements from this list.
  ///
  /// Does not run the component lifecycle; that is done by
  /// [Component.removeAll].
  void _clear() {
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
    _structureVersion++;
    _queries?.clear();
  }

  /// Restores the priority ordering after one or more elements have changed
  /// their [Component.priority].
  ///
  /// Invoked through [Component.rebalanceChildren], which the engine calls at
  /// most once per parent per game tick when priorities of mounted components
  /// change. The sort is stable: components with equal priority keep their
  /// relative order.
  void _rebalance() {
    // Removes all tombstones, which makes the `element!` accesses safe.
    _compact();
    // Not needed for correctness, since every read compacts as well, but it
    // keeps [_QueryCacheStore.resort] from ordering entries that are about to
    // be dropped, by an element index that they no longer have.
    _queries?.compact(this);
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
    _structureVersion++;
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
    _queries?.resort();
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
    return _queries?.isRegistered<C>() ?? false;
  }

  /// Registers [C] as a queryable type, so that [query] can answer in
  /// constant time. Does nothing if the type is already registered.
  void register<C extends Component>() {
    (_queries ??= _QueryCacheStore()).register<C>(this);
  }

  /// All elements of type [C], in priority order, in constant time.
  ///
  /// The type [C] must have been [register]ed beforehand, unless [strictMode]
  /// is false, in which case the registration happens on the first query.
  Iterable<C> query<C extends Component>() {
    final cached = _queries?.find<C>(this);
    if (cached != null) {
      return cached;
    }
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
    return _queries!.find<C>(this)!;
  }

  @override
  Iterable<C> whereType<C>() {
    return _queries?.find<C>(this) ?? super.whereType<C>();
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
