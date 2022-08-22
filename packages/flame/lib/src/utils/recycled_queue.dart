import 'dart:math';

/// [RecycledQueue] is a simple FIFO queue where the elements are recycled.
///
/// That is, the elements [T] in this queue are created and owned by the queue
/// and will not get destroyed when removed from the queue. Instead, these
/// objects will be `dispose()`-d and then released into the pool of unused
/// elements. When new objects are added to the queue, they will be retrieved
/// from the pool if available.
///
/// The API of this class is slightly different from the traditional Queue:
/// - [addLast] appends a new element to the end of the queue and then returns
///   it to the user to fill.
/// - [removeFirst] deletes and disposes of the first element without returning
///   it (use [first] to retrieve the first element beforehand).
///
/// Internally, the queue is backed by a circular list.
class RecycledQueue<T extends Disposable> {
  RecycledQueue(this.factory, {int initialCapacity = 8})
      : assert(initialCapacity > 0),
        _elements = List.generate(initialCapacity, (i) => factory()),
        _startIndex = -1,
        _endIndex = -1;

  /// Function for creating new elements in the queue.
  final T Function() factory;

  /// Index of the first element in the queue, or -1 if the queue is empty.
  int _startIndex;

  /// Index of the last element in the queue, or -1 if the queue is empty. Note
  /// that this index is inclusive.
  int _endIndex;

  /// The backing container.
  ///
  /// Some of the items in this list are considered "active" while others are
  /// "disposed". The [_startIndex] and [_endIndex] describe the range of items
  /// in the list which are "active".
  ///
  /// Two data layouts are possible: the normal one, when [_endIndex] is larger
  /// than or equal to the [_startIndex]:
  ///   [----##############--]
  /// and the wrap-around layout ([_endIndex] < [_startIndex]), which occurs
  /// when the active elements reach the end of the allocated list and start
  /// reusing items in the beginning:
  ///   [###------###########]
  final List<T> _elements;

  bool get isEmpty => _startIndex < 0;
  bool get isNotEmpty => _startIndex >= 0;

  int get length {
    return isEmpty
        ? 0
        : _endIndex >= _startIndex
            ? _endIndex - _startIndex + 1
            : _elements.length - _startIndex + _endIndex + 1;
  }

  T get first {
    assert(isNotEmpty, 'Cannot retrieve first element from an empty queue');
    return _elements[_startIndex];
  }

  /// Adds a new element to the end of the queue, and returns the object added.
  T addLast() {
    if (isEmpty) {
      _startIndex = 0;
      _endIndex = 0;
    }
    // "normal" layout: [---########----]
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
    // "holey" layout: [###-----#####]
    else {
      _endIndex += 1;
      if (_endIndex == _startIndex) {
        final newLength = min(_elements.length, 32);
        final newEntries = List<T>.generate(newLength, (i) => factory());
        _elements.insertAll(_endIndex - 1, newEntries);
        _startIndex += newLength;
      }
    }
    return _elements[_endIndex];
  }

  /// Removes and disposes of the first element in the queue. The queue must
  /// not be empty.
  ///
  /// The removed element is not returned (because it is disposed). Use [first]
  /// in order to peek at the first element before removing it.
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
  }
}

/// The interface for the elements allowed in the [RecycledQueue].
abstract class Disposable {
  void dispose();
}
