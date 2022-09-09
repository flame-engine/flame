import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

/// Mixin should be added to Component to bring QuadTree collision support.
/// Do not forget also to add [CollisionCallbacks] mixin.
///
/// If you need to prevent collision of items of different types -
/// reimplement [broadPhaseCheck]. The result of calculation is cached so you
/// should not check here any dynamical parameters, the function intended to be
/// used as pure type checker.
///
/// Use [changeCollisionType] if you need to change component's hitbox
/// collision type at runtime. This is necessary because hitbox type should be
/// updated at [QuadTree] class.
///
/// You can manually remove object's hitbox from collision system
/// using [removeQuadTreeCollision]. Or update it's size or position using
/// [updateQuadTreeCollision]. But usually you don't need to because all is
/// controlled automatically
mixin HasQuadTreeController<T extends HasQuadTreeCollisionDetection>
    on PositionComponent {
  QuadTreeBroadphase get _quadBroadphase {
    final bf = (this as HasGameRef<T>).gameRef.collisionDetection
        as QuadTreeCollisionDetection;
    return bf.quadBroadphase;
  }

  void removeQuadTreeCollision(ShapeHitbox hitbox) {
    _quadBroadphase.remove(hitbox);
  }

  void updateQuadTreeCollision(ShapeHitbox hitbox) {
    _quadBroadphase.updateItemSizeOrPosition(hitbox);
  }

  void changeCollisionType(ShapeHitbox hitbox, CollisionType type) {
    hitbox.collisionType = type;
    if (type == CollisionType.active) {
      _quadBroadphase.activeCollisions.add(hitbox);
    } else {
      _quadBroadphase.activeCollisions.remove(hitbox);
    }
  }

  @mustCallSuper
  bool broadPhaseCheck(PositionComponent other) {
    final myParent = parent;
    final otherParent = other.parent;
    if (myParent is HasQuadTreeController && otherParent is PositionComponent) {
      return myParent.broadPhaseCheck(otherParent);
    }

    return true;
  }
}
