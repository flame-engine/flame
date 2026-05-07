import 'dart:collection';
import 'dart:math';

import 'package:flame/src/collisions/broadphase/collision_prospect.dart';
import 'package:flame/src/collisions/hitboxes/hitbox.dart';

/// A pool of [CollisionProspect] objects that are reused across frames to avoid
/// per-frame allocations.
///
/// Internally uses a private mutable subclass but only exposes the immutable
/// [CollisionProspect] interface. Implements [Iterable] over acquired entries.
class ProspectPool<T extends Hitbox<T>>
    extends IterableBase<CollisionProspect<T>> {
  ProspectPool({this.incrementSize = 1000});

  /// How much the pool should increase in size every time it needs to be made
  /// larger.
  final int incrementSize;
  final _storage = <_MutableCollisionProspect<T>>[];

  /// The number of prospects currently acquired this frame.
  @override
  int get length => _count;
  int _count = 0;

  @override
  Iterator<CollisionProspect<T>> get iterator =>
      _ProspectPoolIterator<T>(_storage, _count);

  /// Returns a [CollisionProspect] populated with [a] and [b], reusing a
  /// pooled object or expanding the pool as needed.
  CollisionProspect<T> acquire(T a, T b) {
    if (_storage.length <= _count) {
      _expand(a);
    }
    final prospect = _storage[_count]..set(a, b);
    _count++;
    return prospect;
  }

  /// Copies all prospects from [source] into the pool, expanding capacity at
  /// most once.
  void acquireAll(Iterable<CollisionProspect<T>> source) {
    final needed = source is List ? source.length : null;
    if (needed != null && _storage.length < _count + needed) {
      _expand(source.first.a, needed: needed);
    }
    for (final prospect in source) {
      acquire(prospect.a, prospect.b);
    }
  }

  /// Resets the pool for the next frame. Previously acquired prospects should
  /// not be accessed after this call.
  void reset() {
    _count = 0;
  }

  /// Returns the [CollisionProspect] at [index] (must be < [length]).
  CollisionProspect<T> operator [](int index) => _storage[index];

  void _expand(T dummyItem, {int? needed}) {
    final actualIncrement = needed == null
        ? incrementSize
        : max(needed, incrementSize);
    final target = _storage.length + actualIncrement;
    while (_storage.length < target) {
      _storage.add(_MutableCollisionProspect<T>(dummyItem, dummyItem));
    }
  }
}

class _ProspectPoolIterator<T extends Hitbox<T>>
    implements Iterator<CollisionProspect<T>> {
  _ProspectPoolIterator(this._storage, this._length);

  final List<_MutableCollisionProspect<T>> _storage;
  final int _length;
  int _index = -1;

  @override
  CollisionProspect<T> get current => _storage[_index];

  @override
  bool moveNext() => ++_index < _length;
}

/// Private mutable implementation of [CollisionProspect] used exclusively by
/// [ProspectPool] to reuse objects across frames.
///
/// Safety: mutation only happens inside [ProspectPool.acquire] and
/// [ProspectPool.reset], which are never called while prospects are stored in
/// hash-based collections. All access outside this file is through the
/// immutable [CollisionProspect] interface.
// ignore: must_be_immutable
class _MutableCollisionProspect<T> extends CollisionProspect<T> {
  _MutableCollisionProspect(this._a, this._b);

  T _a;
  T _b;

  @override
  T get a => _a;
  @override
  T get b => _b;

  void set(T a, T b) {
    _a = a;
    _b = b;
  }
}
