import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/collisions.dart';
import 'package:flame/geometry.dart';

class Sweep<T extends Hitbox<T>> extends Broadphase<T> {
  Sweep({super.items});

  late final List<T> _active = [];
  late final Set<CollisionProspect<T>> _potentials = {};
  late final List<T> _raycastPotentials = [];

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
  List<T> raycast(Ray2 ray) {
    _raycastPotentials.clear();
    final normalDirection = !ray.direction.x.isNegative;
    var currentMax = items.firstOrNull?.aabb.max.x ?? 0;
    var currentMin = items.firstOrNull?.aabb.min.x ?? 0;

    for (var i = 0; i < items.length; i++) {
      final item = normalDirection ? items[i] : items[items.length - i - 1];
      if (item.collisionType == CollisionType.inactive) {
        continue;
      }
      final currentBox = item.aabb;
      currentMax = max(currentMax, currentBox.max.x);
      currentMin = min(currentMin, currentBox.min.x);
      if (normalDirection) {
        if (currentMax < ray.origin.x) {
          // The ray starts further to the right than the current max and has a
          // direction to the left and since the items are sorted in reverse
          // order along the x-axis we know that it can't hit any of the
          // following items in the list.
          break;
        }
      } else {
        if (currentMin > ray.origin.x) {
          // The ray starts further to the left than the current min and has a
          // direction to the left and since the items are sorted along the
          // x-axis we know that it can't hit any of the following items in the
          // list.
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
