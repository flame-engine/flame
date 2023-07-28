import 'package:flame/collisions.dart';

class Sweep<T extends Hitbox<T>> extends Broadphase<T> {
  Sweep({List<T>? items}) : items = items ?? [];

  @override
  final List<T> items;

  final _active = <T>[];
  final _potentials = <int, CollisionProspect<T>>{};
  final _prospectPool = ProspectPool<T>();

  @override
  void add(T item) => items.add(item);

  @override
  void remove(T item) => items.remove(item);

  @override
  void update() {
    items.sort((a, b) => a.aabb.min.x.compareTo(b.aabb.min.x));
  }

  @override
  Iterable<CollisionProspect<T>> query() {
    _active.clear();
    _potentials.clear();

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
            if (_prospectPool.length <= _potentials.length) {
              _prospectPool.expand(item);
            }
            final prospect = _prospectPool[_potentials.length]
              ..set(item, activeItem);
            _potentials[prospect.hash] = prospect;
          }
        } else {
          _active.remove(activeItem);
        }
      }
      _active.add(item);
    }
    return _potentials.values;
  }
}
