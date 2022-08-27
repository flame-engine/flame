import 'package:flame/collisions.dart';

class Sweep<T extends Hitbox<T>> extends Broadphase<T> {
  Sweep({super.items});

  late final List<T> _active = [];
  late final Set<CollisionProspect<T>> _potentials = {};

  @override
  void update() {
    items.sort((a, b) => a.aabb.min.x.compareTo(b.aabb.min.x));
  }

  @override
  Set<CollisionProspect<T>> query() {
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
            _potentials.add(CollisionProspect<T>(item, activeItem));
          }
        } else {
          _active.remove(activeItem);
        }
      }
      _active.add(item);
    }
    return _potentials;
  }
}
