import 'package:flame/collisions.dart';
import 'package:flame/geometry.dart';

class Sweep<T extends Hitbox<T>> extends Broadphase<T> {
  Sweep({super.items});

  late final List<T> _active = [];
  late final Set<CollisionProspect<T>> _potentials = {};
  late final Set<RaycastResult<T>> _raycastPotentials = {};

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
  Set<RaycastResult<T>>? raycast(Ray2 ray, {Iterable<RaycastResult<T>>? out}) {
    _raycastPotentials.clear();
    final outIterator = out?.iterator;
    items.sort((a, b) => (a.aabb.min.x - b.aabb.min.x).ceil());
    for (final item in items) {
      if (item.collisionType == CollisionType.inactive) {
        continue;
      }
      final currentBox = item.aabb;
      if (ray.direction.x <= 0) {
        if (currentBox.min.x > ray.origin.x) {
          break;
        }
        if ((currentBox.max.x - ray.origin.x) > 0) {
          continue;
        }
      } else {
        if ((currentBox.max.x - ray.origin.x) <= 0) {
          continue;
        }
      }

      if (ray.intersectsWithAabb2(currentBox)) {
        final potential = (outIterator?.moveNext() ?? false)
            ? outIterator!.current
            : RaycastResult(hitbox: item);
        _raycastPotentials.add(potential);
      }
    }
    return _raycastPotentials;
  }
}
