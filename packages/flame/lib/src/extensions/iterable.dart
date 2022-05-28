extension IterableExtension<E> on Iterable<E> {
  /// Similar to [map], but also supplies index of each element.
  Iterable<T> indexedMap<T>(T Function(int index, E e) mapFunction) =>
      _MappedIterable<E, T>(this, mapFunction);
}

typedef _IndexedMapFn<E, T> = T Function(int index, E element);

class _MappedIterable<E, T> extends Iterable<T> {
  _MappedIterable(this._iterable, this._transform);

  final Iterable<E> _iterable;
  final _IndexedMapFn<E, T> _transform;

  @override
  Iterator<T> get iterator =>
      _IndexedMappedIterator<E, T>(_iterable.iterator, _transform);

  // Length related functions are independent of the mapping.
  @override
  int get length => _iterable.length;
  @override
  bool get isEmpty => _iterable.isEmpty;

  // Index based lookup can be done before transforming.
  @override
  T get first => _transform(0, _iterable.first);
  @override
  T get last => _transform(length - 1, _iterable.last);
  @override
  T get single => _transform(0, _iterable.single);
  @override
  T elementAt(int index) => _transform(index, _iterable.elementAt(index));
}

class _IndexedMappedIterator<E, T> extends Iterator<T> {
  _IndexedMappedIterator(this._iterator, this._transform);

  int _index = 0;
  T? _current;
  final Iterator<E> _iterator;
  final _IndexedMapFn<E, T> _transform;

  @override
  bool moveNext() {
    if (_iterator.moveNext()) {
      _current = _transform(_index, _iterator.current);
      _index++;
      return true;
    }
    _current = null;
    return false;
  }

  @override
  T get current => _current as T;
}
