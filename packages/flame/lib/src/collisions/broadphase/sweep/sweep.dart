import 'package:collection/collection.dart';
import 'package:flame/collisions.dart';

class Sweep<T extends Hitbox<T>> extends Broadphase<T> {
  Sweep({List<T>? items}) : items = items ?? [];

  @override
  final List<T> items;

  final _active = <T>[];
  final _prospectPool = ProspectPool<T>();

  @override
  void add(T item) => items.add(item);

  @override
  void remove(T item) => items.remove(item);

  @override
  void update() {
    // Between two ticks the hitboxes only move a little, so [items] is
    // always nearly sorted: an insertion sort runs in close to linear time
    // here, where a general-purpose sort would pay its full O(n log n) on
    // every tick. The comparator is a static tear-off, so nothing is
    // allocated per tick.
    insertionSort(items, compare: _compareMinX);
  }

  static int _compareMinX(Hitbox<dynamic> a, Hitbox<dynamic> b) =>
      a.aabb.min.x.compareTo(b.aabb.min.x);

  @override
  Iterable<CollisionProspect<T>> query() {
    _active.clear();
    _prospectPool.reset();

    for (final item in items) {
      if (item.collisionType == CollisionType.inactive) {
        continue;
      }
      if (_active.isEmpty) {
        _active.add(item);
        continue;
      }
      final currentBox = item.aabb;
      final currentMin = currentBox.min.x;
      for (var i = _active.length - 1; i >= 0; i--) {
        final activeItem = _active[i];
        final activeBox = activeItem.aabb;
        if (activeBox.max.x >= currentMin) {
          if (item.collisionType == CollisionType.active ||
              activeItem.collisionType == CollisionType.active) {
            _prospectPool.acquire(item, activeItem);
          }
        } else {
          // The order of the active list does not matter, so the removal can
          // swap in the last element instead of searching and shifting.
          _active[i] = _active.last;
          _active.removeLast();
        }
      }
      _active.add(item);
    }
    return _prospectPool;
  }
}
