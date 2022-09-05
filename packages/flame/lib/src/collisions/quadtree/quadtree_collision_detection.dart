import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/widgets.dart';

/// Collision detection modification to support Quad Tree.
/// Do not use standard [items] list fo components. Instead adds all components
/// into [QuadTreeBroadphase] class.
///
class QuadTreeCollisionDetection extends StandardCollisionDetection {
  QuadTreeCollisionDetection({
    required Rect mapDimensions,
    required ExternalBroadphaseCheck broadphaseCheck,
    required ExternalMinDistanceCheck minimumDistanceCheck,
    int maxObjects = 25,
    int maxLevels = 10,
  }) : super(
          broadphase: QuadTreeBroadphase<ShapeHitbox>(
              mainBoxSize: mapDimensions,
              maxObjects: maxObjects,
              maxLevels: maxLevels,
              broadphaseCheck: broadphaseCheck,
              minimumDistanceCheck: minimumDistanceCheck),
        );

  QuadTreeBroadphase get quadBroadphase => broadphase as QuadTreeBroadphase;

  @override
  void add(ShapeHitbox item) {
    super.add(item);
    quadBroadphase.add(item);
  }

  @override
  void addAll(Iterable<ShapeHitbox> items) {
    items.forEach(add);
  }

  @override
  void remove(ShapeHitbox item) {
    quadBroadphase.remove(item);
    super.remove(item);
  }

  @override
  void removeAll(Iterable<ShapeHitbox> items) {
    quadBroadphase.clear();
    super.removeAll(items);
  }
}
