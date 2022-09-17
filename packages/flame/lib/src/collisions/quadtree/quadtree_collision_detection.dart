import 'package:flame/collisions.dart';
import 'package:flutter/widgets.dart';

/// Collision detection modification to support a Quad Tree broadphase.
///
/// Do not use standard [items] list for components. Instead adds all components
/// into [QuadTreeBroadphase] class.
class QuadTreeCollisionDetection
    extends StandardCollisionDetection<QuadTreeBroadphase<ShapeHitbox>> {
  QuadTreeCollisionDetection({
    required Rect mapDimensions,
    required ExternalBroadphaseCheck onComponentTypeCheck,
    required ExternalMinDistanceCheck minimumDistanceCheck,
    int maxObjects = 25,
    int maxDepth = 10,
  }) : super(
          broadphase: QuadTreeBroadphase<ShapeHitbox>(
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
    super.add(item);

    item.onAabbChanged = () => _scheduledUpdate.add(item);
    // ignore: prefer_function_declarations_over_variables
    final listenerCollisionType = () {
      if (item.isMounted) {
        if (item.collisionType == CollisionType.active) {
          broadphase.activeCollisions.add(item);
        } else {
          broadphase.activeCollisions.remove(item);
        }
      }
    };
    item.collisionTypeNotifier.addListener(listenerCollisionType);
    _listenerCollisionType[item] = listenerCollisionType;

    broadphase.add(item);
  }

  @override
  void addAll(Iterable<ShapeHitbox> items) {
    items.forEach(add);
  }

  @override
  void remove(ShapeHitbox item) {
    item.onAabbChanged = null;
    final listenerCollisionType = _listenerCollisionType[item];
    if (listenerCollisionType != null) {
      item.collisionTypeNotifier.removeListener(listenerCollisionType);
      _listenerCollisionType.remove(item);
    }

    broadphase.remove(item);
    super.remove(item);
  }

  @override
  void removeAll(Iterable<ShapeHitbox> items) {
    broadphase.clear();
    items.forEach(remove);
  }

  @override
  void run() {
    _scheduledUpdate.forEach(
      broadphase.updateTransform,
    );
    _scheduledUpdate.clear();
    super.run();
  }
}
