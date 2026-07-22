part of 'component.dart';

/// A fast, ordered container for a [Component]'s children.
///
/// Variant B: an intrusive doubly-linked list. Each component carries
/// `_prevSibling`/`_nextSibling` pointers, and the container only stores the
/// head and tail of the chain. The children are kept sorted by
/// [Component.priority]; components with equal priority keep the order in
/// which they were added.
///
/// Performance characteristics:
///  - iteration: O(n) pointer walk, no allocations on engine paths;
///  - [add]: O(1) when the component sorts at or after the end (the common
///    case), otherwise O(n) backwards walk to the insertion point;
///  - [remove] and [contains]: O(1) via the intrusive pointers;
///  - [rebalance]: O(n) when still sorted, otherwise O(n log n) stable
///    merge sort.
///
/// Any structural mutation invalidates live iterators, which will then throw
/// a [ConcurrentModificationError].
class ComponentSet extends Iterable<Component> {
  ComponentSet({bool? strictMode})
    : strictMode = strictMode ?? Component.strictQueryMode;

  /// Whether calling [query] for an unregistered type throws an error
  /// (`true`), or transparently registers the type on first use (`false`).
  final bool strictMode;

  Component? _first;
  Component? _last;
  int _length = 0;

  /// Incremented on every structural mutation; iterators use this to detect
  /// concurrent modification.
  int _modCount = 0;

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
    final first = _first;
    if (first == null) {
      throw StateError('No element');
    }
    return first;
  }

  @override
  Component get last {
    final last = _last;
    if (last == null) {
      throw StateError('No element');
    }
    return last;
  }

  @override
  Component elementAt(int index) {
    RangeError.checkNotNegative(index, 'index');
    var i = 0;
    for (var node = _first; node != null; node = node._nextSibling) {
      if (i++ == index) {
        return node;
      }
    }
    throw IndexError.withLength(index, _length, indexable: this);
  }

  @override
  void forEach(void Function(Component element) action) {
    var node = _first;
    while (node != null) {
      final next = node._nextSibling;
      action(node);
      node = next;
    }
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
    final priority = component._priority;
    final last = _last;
    var appended = false;
    if (last == null) {
      _first = component;
      _last = component;
      appended = true;
    } else if (last._priority <= priority) {
      last._nextSibling = component;
      component._prevSibling = last;
      _last = component;
      appended = true;
    } else {
      // Walk backwards to find the last node with priority <= the new one.
      var node = last;
      while (true) {
        final prev = node._prevSibling;
        if (prev == null || prev._priority <= priority) {
          break;
        }
        node = prev;
      }
      // Insert before [node].
      final prev = node._prevSibling;
      component._prevSibling = prev;
      component._nextSibling = node;
      node._prevSibling = component;
      if (prev == null) {
        _first = component;
      } else {
        prev._nextSibling = component;
      }
    }
    component._containerSet = this;
    _length++;
    _modCount++;
    final queries = _queries;
    if (queries != null) {
      for (final cache in queries.values) {
        if (cache.check(component)) {
          if (appended) {
            cache.append(component);
          } else {
            cache.dirty = true;
          }
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
    final prev = component._prevSibling;
    final next = component._nextSibling;
    if (prev == null) {
      _first = next;
    } else {
      prev._nextSibling = next;
    }
    if (next == null) {
      _last = prev;
    } else {
      next._prevSibling = prev;
    }
    component._prevSibling = null;
    component._nextSibling = null;
    component._containerSet = null;
    _length--;
    _modCount++;
    final queries = _queries;
    if (queries != null) {
      for (final cache in queries.values) {
        if (cache.check(component)) {
          if (cache.dirty) {
            continue;
          }
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
    var node = _first;
    while (node != null) {
      final next = node._nextSibling;
      node._prevSibling = null;
      node._nextSibling = null;
      node._containerSet = null;
      node = next;
    }
    _first = null;
    _last = null;
    _length = 0;
    _modCount++;
    _queries?.forEach((_, cache) {
      cache.data.clear();
      cache.dirty = false;
    });
  }

  /// Restores the priority ordering after one or more elements have changed
  /// their [Component.priority].
  ///
  /// This is invoked automatically, at most once per parent per game tick,
  /// when priorities of mounted components change. The sort is stable:
  /// components with equal priority keep their relative order.
  void rebalance() {
    if (_length < 2) {
      return;
    }
    var isSorted = true;
    for (var node = _first; node != null; node = node._nextSibling) {
      final next = node._nextSibling;
      if (next != null && node._priority > next._priority) {
        isSorted = false;
        break;
      }
    }
    if (isSorted) {
      return;
    }
    final elements = toList(growable: false);
    mergeSort<Component>(
      elements,
      compare: (a, b) => a._priority.compareTo(b._priority),
    );
    Component? prev;
    for (var i = 0; i < elements.length; i++) {
      final node = elements[i];
      node._prevSibling = prev;
      node._nextSibling = null;
      if (prev == null) {
        _first = node;
      } else {
        prev._nextSibling = node;
      }
      prev = node;
    }
    _last = prev;
    _modCount++;
    _queries?.forEach((_, cache) => cache.dirty = true);
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
    final cache = _QueryCache<C>();
    _fillCache(cache);
    queries[C] = cache;
  }

  void _fillCache(_QueryCache<Component> cache) {
    for (var node = _first; node != null; node = node._nextSibling) {
      if (cache.check(node)) {
        cache.append(node);
      }
    }
    cache.dirty = false;
  }

  /// All elements of type [C], in priority order, in O(1) (amortized: a
  /// cache invalidated by a reorder is lazily rebuilt on the next query).
  Iterable<C> query<C extends Component>() {
    final cache = _queries?[C];
    if (cache == null) {
      if (strictMode) {
        throw StateError('Cannot query unregistered query $C');
      }
      register<C>();
      return query<C>();
    }
    if (cache.dirty) {
      cache.data.clear();
      _fillCache(cache);
    }
    return cache.data as Iterable<C>;
  }

  @override
  Iterable<C> whereType<C>() {
    final cache = _queries?[C];
    if (cache != null) {
      if (cache.dirty) {
        cache.data.clear();
        _fillCache(cache);
      }
      return cache.data as Iterable<C>;
    }
    return super.whereType<C>();
  }
}

class _ComponentSetIterator implements Iterator<Component> {
  _ComponentSetIterator(this._set)
    : _modCount = _set._modCount,
      _next = _set._first;

  final ComponentSet _set;
  final int _modCount;
  Component? _next;
  Component? _current;

  @override
  Component get current => _current!;

  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  @override
  bool moveNext() {
    if (_set._modCount != _modCount) {
      throw ConcurrentModificationError(_set);
    }
    final current = _next;
    if (current == null) {
      _current = null;
      return false;
    }
    _current = current;
    _next = current._nextSibling;
    return true;
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
  _ReversedComponentSetIterator(this._set)
    : _modCount = _set._modCount,
      _next = _set._last;

  final ComponentSet _set;
  final int _modCount;
  Component? _next;
  Component? _current;

  @override
  Component get current => _current!;

  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  @override
  bool moveNext() {
    if (_set._modCount != _modCount) {
      throw ConcurrentModificationError(_set);
    }
    final current = _next;
    if (current == null) {
      _current = null;
      return false;
    }
    _current = current;
    _next = current._prevSibling;
    return true;
  }
}

/// A cached result of `query<C>()`. When an operation would make incremental
/// maintenance expensive (mid-list insertion or a reorder), the cache is
/// marked dirty and rebuilt on the next query instead.
class _QueryCache<C extends Component> {
  final List<C> data = [];
  bool dirty = false;

  bool check(Component component) => component is C;

  void append(Component component) => data.add(component as C);
}
