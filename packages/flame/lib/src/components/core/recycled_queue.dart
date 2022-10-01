import 'dart:collection';
import 'dart:math';

/// [RecycledQueue] is a simple FIFO queue where the elements are recycled.
///
/// The elements [T] in this queue are created and owned by the queue and will
/// not get destroyed when removed from the queue. Instead, these objects will
/// be `dispose`-d and then released into the pool of unused elements. When new
/// objects are added to the queue, the previously disposed elements will be
/// reused.
///
/// The API of this class is slightly different from the traditional Queue:
/// - [addLast] mints a new element and appends it to the end of the queue,
///   then returns that element for the user to fill.
/// - [removeFirst] deletes and disposes of the first element without returning
///   it (use [first] to retrieve the first element beforehand).
///
/// In addition, the queue can be iterated over, and modified during that
/// iteration via the methods [removeCurrent] and [addLast]. However, only one
/// iterator is allowed at a time.
///
/// Internally, the queue is backed by a circular list.
class RecycledQueue<T extends Disposable> extends IterableMixin<T>
    implements Iterable<T>, Iterator<T> {
  RecycledQueue(this.factory, {int initialCapacity = 8})
      : _elements = List.generate(initialCapacity, (i) => factory()),
        _startIndex = -1,
        _endIndex = -1,
        _currentIndex = -1;

  /// Function for creating new elements in the queue.
  final T Function() factory;

  /// Index of the first element in the queue, or -1 if the queue is empty.
  int _startIndex;

  /// Index of the last element in the queue, or -1 if the queue is empty. This
  /// index is inclusive, and can be greater, equal, or less than [_startIndex].
  int _endIndex;

  /// Index of the [current] element while iterating, or -1 if not iterating.
  /// Also, the value -2 indicates the start of a new iteration.
  int _currentIndex;

  /// The backing container of elements [T].
  ///
  /// Some of the items in this list are considered "active" while others are
  /// "disposed". The [_startIndex] and [_endIndex] describe the range of items
  /// in the list which are "active".
  ///
  /// Two data layouts are possible: the normal one, when [_endIndex] is larger
  /// than or equal to the [_startIndex]:
  /// ```
  ///   [----S############E--]
  /// ```
  /// and the wrap-around layout ([_endIndex] < [_startIndex]), which occurs
  /// when the active elements reach the end of the allocated list and start
  /// reusing items in the beginning:
  /// ```
  ///   [##E------S##########]
  /// ```
  final List<T> _elements;

  /// The list of indices of elements that ought to be removed: this list is
  /// populated when elements are removed during the iteration, and then the
  /// elements are physically removed at the end of the iteration.
  List<int> _indicesToRemove = [];

  @override
  bool get isEmpty => _startIndex < 0;

  @override
  bool get isNotEmpty => _startIndex >= 0;

  @override
  int get length {
    return isEmpty
        ? 0
        : _endIndex >= _startIndex
            ? _endIndex - _startIndex + 1
            : _elements.length - _startIndex + _endIndex + 1;
  }

  @override
  T get first {
    assert(isNotEmpty, 'Cannot retrieve elements from an empty queue');
    return _elements[_startIndex];
  }

  @override
  T get last {
    assert(isNotEmpty, 'Cannot retrieve elements from an empty queue');
    return _elements[_endIndex];
  }

  /// Adds a new element to the end of the queue, and returns the object added.
  ///
  /// This method can be called even while iterating over the queue.
  T addLast() {
    // "empty" layout: [---------------]
    if (isEmpty) {
      _startIndex = 0;
      _endIndex = 0;
      if (_elements.isEmpty) {
        _elements.add(factory());
      }
    }
    // "normal" layout: [---S######E----]
    else if (_endIndex >= _startIndex) {
      _endIndex += 1;
      if (_endIndex == _elements.length) {
        if (_startIndex == 0) {
          final newElement = factory();
          _elements.add(newElement);
        } else {
          _endIndex = 0;
        }
      }
    }
    // "wrap-around": [#######ES######]
    else if (_endIndex == _startIndex - 1) {
      final numItemsToAdd = min(_elements.length, 32);
      final newEntries = List<T>.generate(numItemsToAdd, (i) => factory());
      _elements.insertAll(_startIndex, newEntries);
      _startIndex += numItemsToAdd;
      if (_currentIndex > _endIndex) {
        _currentIndex += numItemsToAdd;
      }
      for (var i = 0; i < _indicesToRemove.length; i++) {
        if (_indicesToRemove[i] > _endIndex) {
          _indicesToRemove[i] += numItemsToAdd;
        }
      }
      _endIndex += 1;
      assert(_endIndex < _startIndex);
    }
    // "holey" layout: [##E-----S######]
    else {
      _endIndex += 1;
      assert(_endIndex < _startIndex);
    }
    return _elements[_endIndex];
  }

  /// Removes and disposes of the first element in the queue. The queue must
  /// not be empty.
  ///
  /// The removed element is not returned (because it is disposed). Use [first]
  /// in order to peek at the first element before removing it.
  ///
  /// Calling this method while iterating will stop iteration.
  void removeFirst() {
    assert(isNotEmpty, 'Cannot remove elements from an empty queue');
    _elements[_startIndex].dispose();
    if (_startIndex == _endIndex) {
      _startIndex = -1;
      _endIndex = -1;
    } else {
      _startIndex += 1;
      if (_startIndex == _elements.length) {
        _startIndex = 0;
      }
    }
    _currentIndex = -1;
  }

  /// Removes and disposes the [current] element, while iterating over the
  /// queue. It is an error to call this method while not iterating, or to
  /// access the [current] element after it was removed.
  void removeCurrent() {
    assert(
      _currentIndex >= 0,
      'Cannot remove current element if not iterating',
    );
    _elements[_currentIndex].dispose();
    if (_startIndex == _endIndex) {
      assert(_currentIndex == _startIndex);
      _startIndex = -1;
      _endIndex = -1;
      _currentIndex = -1;
    } else if (_currentIndex == _startIndex) {
      _startIndex += 1;
      if (_startIndex == _elements.length) {
        _startIndex = 0;
      }
    } else {
      _indicesToRemove.add(_currentIndex);
    }
  }

  @override
  Iterator<T> get iterator {
    _garbageCollect();
    _currentIndex = -2;
    return this;
  }

  @override
  T get current {
    assert(
      _currentIndex >= 0,
      'The [current] getter is only accessible while iterating',
    );
    return _elements[_currentIndex];
  }

  @override
  bool moveNext() {
    if (isEmpty || _currentIndex == -1) {
      _currentIndex = -1;
      return false;
    }
    if (_currentIndex < 0) {
      _currentIndex = _startIndex;
    } else if (_currentIndex == _endIndex) {
      _currentIndex = -1;
      _garbageCollect();
      return false;
    } else {
      _currentIndex += 1;
      if (_currentIndex == _elements.length) {
        _currentIndex = 0;
      }
    }
    return true;
  }

  void _garbageCollect() {
    if (_indicesToRemove.isEmpty) {
      return;
    }
    final it = _indicesToRemove.iterator;
    var nextIndexToRemove = (it..moveNext()).current;
    var lastValidIndex = -1;
    var i = _startIndex;
    var j = _startIndex;
    int advanceIndex(int i) {
      return (i == _endIndex)
          ? -1
          : (i == _elements.length - 1)
              ? 0
              : i + 1;
    }

    while (i != -1) {
      if (i == nextIndexToRemove) {
        if (it.moveNext()) {
          nextIndexToRemove = it.current;
        } else {
          nextIndexToRemove = -1;
        }
        i = advanceIndex(i);
      } else {
        if (i != j) {
          final t = _elements[i];
          _elements[i] = _elements[j];
          _elements[j] = t;
        }
        lastValidIndex = j;
        i = advanceIndex(i);
        j = advanceIndex(j);
      }
    }
    assert(nextIndexToRemove == -1);
    assert(lastValidIndex != -1);
    _endIndex = lastValidIndex;
    _indicesToRemove.clear();
  }

  /// [toString] can be called while iterating, though it may show up disposed
  /// elements if the main iteration is also removing elements from the queue.
  @override
  String toString() {
    final savedIndicesToRemove = _indicesToRemove;
    final savedCurrentIndex = _currentIndex;
    _currentIndex = -1;
    _indicesToRemove = const <int>[];
    final out = 'RecycledQueue${super.toString()}';
    _currentIndex = savedCurrentIndex;
    _indicesToRemove = savedIndicesToRemove;
    return out;
  }
}

/// The interface for the elements allowed in the [RecycledQueue].
abstract class Disposable {
  void dispose();
}
