import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

/// Collision detection modification to support a Quad Tree broadphase.
///
/// Do not use standard [items] list for components. Instead adds all components
/// into [QuadTreeBroadphase] class.
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
            minimumDistanceCheck: minimumDistanceCheck,
          ),
        );

  QuadTreeBroadphase get quadBroadphase => broadphase as QuadTreeBroadphase;

  final _listenerTransform = <ShapeHitbox, VoidCallback>{};
  final _listenerCollisionType = <ShapeHitbox, VoidCallback>{};
  final _scheduledUpdate = <ShapeHitbox>{};

  @override
  void add(ShapeHitbox item) {
    super.add(item);
    // ignore: prefer_function_declarations_over_variables
    final listenerTransform = () {
      if (item.isMounted) {
        _scheduledUpdate.add(item);
      }
    };
    final parent = item.parent;
    if (parent != null && parent is PositionComponent) {
      parent.position.addListener(listenerTransform);
    }
    item.size.addListener(listenerTransform);
    _listenerTransform[item] = listenerTransform;

    // ignore: prefer_function_declarations_over_variables
    final listenerCollisionType = () {
      if (item.isMounted) {
        if (item.collisionType == CollisionType.active) {
          quadBroadphase.activeCollisions.add(item);
        } else {
          quadBroadphase.activeCollisions.remove(item);
        }
      }
    };
    item.addCollisionTypeListener(listenerCollisionType);
    _listenerCollisionType[item] = listenerCollisionType;

    quadBroadphase.add(item);
  }

  @override
  void addAll(Iterable<ShapeHitbox> items) {
    items.forEach(add);
  }

  @override
  void remove(ShapeHitbox item) {
    final listenerTransform = _listenerTransform[item];
    if (listenerTransform != null) {
      final parent = item.parent;
      if (parent != null && parent is PositionComponent) {
        parent.position.removeListener(listenerTransform);
      }
      item.size.removeListener(listenerTransform);
      _listenerTransform.remove(item);
    }

    final listenerCollisionType = _listenerCollisionType[item];
    if (listenerCollisionType != null) {
      item.removeCollisionTypeListener(listenerCollisionType);
      _listenerCollisionType.remove(item);
    }

    quadBroadphase.remove(item);
    super.remove(item);
  }

  @override
  void removeAll(Iterable<ShapeHitbox> items) {
    quadBroadphase.clear();
    items.forEach(remove);
  }

  @override
  void run() {
    _scheduledUpdate.forEach(
      quadBroadphase.updateItemSizeOrPosition,
    );
    _scheduledUpdate.clear();
    super.run();
  }
}
