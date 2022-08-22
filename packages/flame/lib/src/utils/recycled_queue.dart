import 'dart:math';

/// [RecycledQueue] is a simple FIFO queue where the elements are recycled.
class RecycledQueue<T extends Disposable> {
  RecycledQueue(this.factory, {int initialCapacity = 8})
      : assert(initialCapacity > 0),
        _elements = List.generate(initialCapacity, (i) => factory()),
        _startIndex = -1,
        _endIndex = -1;

  final T Function() factory;
  final List<T> _elements;

  /// Index of the first element in the queue, or -1 if the queue is empty.
  int _startIndex;

  /// Index of the last element in the queue, or -1 if the queue is empty.
  int _endIndex;

  bool get isEmpty => _startIndex < 0;
  bool get isNotEmpty => _startIndex >= 0;

  int get length {
    return isEmpty
        ? 0
        : _endIndex >= _startIndex
            ? _endIndex - _startIndex + 1
            : _elements.length - _endIndex + _startIndex + 1;
  }

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

  T get first {
    assert(isNotEmpty, 'Cannot retrieve first element from an empty queue');
    return _elements[_startIndex];
  }

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

abstract class Disposable {
  void dispose();
}
