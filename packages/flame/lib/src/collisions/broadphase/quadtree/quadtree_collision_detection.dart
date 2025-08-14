import 'package:flame/collisions.dart';
import 'package:flutter/widgets.dart';

/// Collision detection modification to support a Quad Tree broadphase.
///
/// Do not use standard [items] list for components. Instead adds all components
/// into [QuadTreeBroadphase] class.
class QuadTreeCollisionDetection
    extends StandardCollisionDetection<QuadTreeBroadphase> {
  QuadTreeCollisionDetection({
    required Rect mapDimensions,
    required ExternalBroadphaseCheck onComponentTypeCheck,
    required ExternalMinDistanceCheck minimumDistanceCheck,
    int maxObjects = 25,
    int maxDepth = 10,
  }) : super(
         broadphase: QuadTreeBroadphase(
           mainBoxSize: mapDimensions,
           maxObjects: maxObjects,
           maxDepth: maxDepth,
           broadphaseCheck: onComponentTypeCheck,
           minimumDistanceCheck: minimumDistanceCheck,
         ),
       );

  final _listenerCollisionType = <ShapeHitbox, VoidCallback>{};
  final _scheduledUpdate = <ShapeHitbox>{};

  @override
  void add(ShapeHitbox item) {
    item.onAabbChanged = () => _scheduledUpdate.add(item);
    void listenerCollisionType() {
      if (item.isMounted) {
        if (item.collisionType == CollisionType.active) {
          broadphase.activeHitboxes.add(item);
        } else {
          broadphase.activeHitboxes.remove(item);
        }
      }
    }

    item.collisionTypeNotifier.addListener(listenerCollisionType);
    _listenerCollisionType[item] = listenerCollisionType;

    super.add(item);
  }

  @override
  void addAll(Iterable<ShapeHitbox> items) {
    for (final item in items) {
      add(item);
    }
  }

  @override
  void remove(ShapeHitbox item) {
    item.onAabbChanged = null;
    final listenerCollisionType = _listenerCollisionType[item];
    if (listenerCollisionType != null) {
      item.collisionTypeNotifier.removeListener(listenerCollisionType);
      _listenerCollisionType.remove(item);
    }

    super.remove(item);
  }

  @override
  void removeAll(Iterable<ShapeHitbox> items) {
    broadphase.clear();
    for (final item in items) {
      remove(item);
    }
  }

  @override
  void run() {
    for (final hitbox in _scheduledUpdate) {
      broadphase.updateTransform(hitbox);
    }
    _scheduledUpdate.clear();
    super.run();
  }
}
