import 'package:meta/meta.dart';

import '../../collision_detection.dart';
import '../../components.dart';

/// This mixin can be used if you want to pass the [CollisionCallbacks] to the
/// next ancestor that can receive them. It can be used to group hitboxes
/// together on a component, that then is added to another component that also
/// cares about the collision events of the hitboxes.
mixin CollisionPassthrough on CollisionCallbacks {
  /// The parent that the events should be passed on to.
  CollisionCallbacks? passthroughParent;

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    passthroughParent = ancestors().firstWhere(
      (c) => c is CollisionCallbacks,
    ) as CollisionCallbacks;
  }

  @override
  @mustCallSuper
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    passthroughParent?.onCollision(intersectionPoints, other);
  }

  @override
  @mustCallSuper
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    passthroughParent?.onCollisionStart(intersectionPoints, other);
  }

  @override
  @mustCallSuper
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    passthroughParent?.onCollisionEnd(other);
  }
}
