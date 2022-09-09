import 'dart:collection';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

typedef ExternalBroadphaseCheck = bool Function(
  PositionComponent one,
  PositionComponent another,
);

typedef ExternalMinDistanceCheck = bool Function(
  Vector2 activeItemCenter,
  Vector2 potentialCenter,
);

/// Performs Quad Tree broadphase check.
///
/// See [HasQuadTreeCollisionDetection.initCollisionDetection] for a detailed
/// description of its initialization parameters.
class QuadTreeBroadphase<T extends Hitbox<T>> extends Broadphase<T> {
  QuadTreeBroadphase({
    super.items,
    required Rect mainBoxSize,
    required this.broadphaseCheck,
    required this.minimumDistanceCheck,
    int maxObjects = 25,
    int maxLevels = 10,
  }) : tree = QuadTree<T>(
          mainBoxSize: mainBoxSize,
          maxObjects: maxObjects,
          maxLevels: maxLevels,
        );

  final QuadTree tree;

  final activeCollisions = HashSet<T>();

  ExternalBroadphaseCheck broadphaseCheck;
  ExternalMinDistanceCheck minimumDistanceCheck;
  final _broadphaseCheckCache = <T, Map<T, bool>>{};

  final _cachedCenters = <ShapeHitbox, Vector2>{};

  final potentials = HashSet<CollisionProspect<T>>();
  final potentialsTmp = <List<ShapeHitbox>>[];

  @override
  HashSet<CollisionProspect<T>> query() {
    potentials.clear();
    potentialsTmp.clear();

    for (final activeItem in activeCollisions) {
      final asShapeItem = activeItem as ShapeHitbox;

      if (asShapeItem.isRemoving || asShapeItem.parent == null) {
        tree.remove(activeItem);
        continue;
      }

      final itemCenter = activeItem.aabb.center;
      final markRemove = <ShapeHitbox>[];
      final potentiallyCollide = tree.query(activeItem);
      for (final potential in potentiallyCollide.entries.first.value) {
        if (potential.collisionType == CollisionType.inactive) {
          continue;
        }

        if (_broadphaseCheckCache[activeItem]?[potential] == false) {
          continue;
        }

        final asShapePotential = potential as ShapeHitbox;

        if (asShapePotential.isRemoving || asShapePotential.parent == null) {
          markRemove.add(potential);
          continue;
        }
        if (asShapePotential.parent == asShapeItem.parent &&
            asShapeItem.parent != null) {
          continue;
        }

        Vector2 potentialCenter;
        if (potential.collisionType == CollisionType.passive) {
          potentialCenter = _getCenterOfHitbox(asShapePotential);
        } else {
          potentialCenter = potential.aabb.center;
        }

        final distanceCloseEnough =
            minimumDistanceCheck.call(itemCenter, potentialCenter);
        if (distanceCloseEnough == false) {
          continue;
        }

        potentialsTmp.add([asShapeItem, potential]);
      }
      markRemove.forEach(tree.remove);
    }

    if (potentialsTmp.isNotEmpty) {
      for (var i = 0; i < potentialsTmp.length; i++) {
        final item0 = potentialsTmp[i].first;
        final item1 = potentialsTmp[i].last;
        var keep = broadphaseCheck(item0, item1);
        if (keep) {
          keep = broadphaseCheck(item1, item0);
        }
        if (keep) {
          potentials.add(CollisionProspect(item0 as T, item1 as T));
        } else {
          if (_broadphaseCheckCache[item0 as T] == null) {
            _broadphaseCheckCache[item0 as T] = {};
          }
          _broadphaseCheckCache[item0 as T]![item1 as T] = false;
        }
      }
    }
    return potentials;
  }

  void updateItemSizeOrPosition(T item) {
    tree.remove(item, oldPosition: true);
    if (item.collisionType == CollisionType.passive) {
      _getCenterOfHitbox(item as ShapeHitbox);
    }
    tree.add(item);
  }

  void add(T hitbox) {
    tree.add(hitbox);
    if (hitbox.collisionType == CollisionType.active) {
      activeCollisions.add(hitbox);
    } else if (hitbox.collisionType == CollisionType.passive) {
      _getCenterOfHitbox(hitbox as ShapeHitbox);
    }
  }

  void remove(T item) {
    tree.remove(item);
    if (item.collisionType == CollisionType.active) {
      activeCollisions.remove(item);
    }
  }

  void clear() {
    tree.clear();
    activeCollisions.clear();
    _broadphaseCheckCache.clear();
    _cachedCenters.clear();
  }

  /// Caches hitbox center for passive collision objects, because
  /// calculating on-the-fly is too expensive whereas passive objects usually
  /// not change theirs position or size
  Vector2 _getCenterOfHitbox(ShapeHitbox hitbox) {
    var cache = _cachedCenters[hitbox];
    if (cache == null) {
      _cachedCenters[hitbox] = hitbox.aabb.center;
      cache = _cachedCenters[hitbox];
    }
    return cache!;
  }
}
