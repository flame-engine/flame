import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
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

  final _listenerByHitbox = <ShapeHitbox, VoidCallback>{};
  final _scheduledUpdate = <ShapeHitbox>{};

  @override
  void add(ShapeHitbox item) {
    super.add(item);
    // ignore: prefer_function_declarations_over_variables
    final listener = () {
      _scheduledUpdate.add(item);
    };
    final parent = item.parent;
    if (parent != null && parent is PositionComponent) {
      parent.position.addListener(listener);
    }
    item.size.addListener(listener);

    _listenerByHitbox[item] = listener;
    quadBroadphase.add(item);
  }

  @override
  void addAll(Iterable<ShapeHitbox> items) {
    items.forEach(add);
  }

  @override
  void remove(ShapeHitbox item) {
    final listener = _listenerByHitbox[item];
    if (listener != null) {
      final parent = item.parent;
      if (parent != null && parent is PositionComponent) {
        parent.position.removeListener(listener);
      }
      item.size.removeListener(listener);
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
