import 'package:flame/collisions.dart';
import 'package:flame/geometry.dart';

class Sweep<T extends Hitbox<T>> extends Broadphase<T> {
  Sweep({super.items});

  late final List<T> _active = [];
  late final Set<CollisionProspect<T>> _potentials = {};
  late final Set<T> _raycastPotentials = {};

  @override
  Set<CollisionProspect<T>> query() {
    _active.clear();
    _potentials.clear();
    items.sort((a, b) => (a.aabb.min.x - b.aabb.min.x).ceil());
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

  @override
  Set<T> raycast(Ray2 ray) {
    _raycastPotentials.clear();
    if (ray.direction.x.isNegative) {
      items.sort((a, b) => (a.aabb.min.x - b.aabb.min.x).ceil());
    } else {
      items.sort((a, b) => (b.aabb.max.x - a.aabb.max.x).ceil());
    }

    for (final item in items) {
      if (item.collisionType == CollisionType.inactive) {
        continue;
      }
      final currentBox = item.aabb;
      if (ray.direction.x.isNegative) {
        if (currentBox.min.x > ray.origin.x) {
          // The ray starts further to the left than the current min and has a
          // direction to the left and since the items are sorted along the
          // x-axis we know that it can't hit any of the following items in the
          // list.
          break;
        }
      } else {
        if (currentBox.max.x < ray.origin.x) {
          // The ray starts further to the right than the current max and has a
          // direction to the left and since the items are sorted in reverse
          // order along the x-axis we know that it can't hit any of the
          // following items in the list.
          break;
        }
      }

      if (ray.intersectsWithAabb2(currentBox)) {
        _raycastPotentials.add(item);
      }
    }
    return _raycastPotentials;
  }
}
