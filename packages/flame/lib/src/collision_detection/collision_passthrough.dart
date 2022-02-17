import 'package:meta/meta.dart';

import '../../collision_detection.dart';
import '../../components.dart';

/// This mixin can be used if you want to pass the [CollisionCallbacks] to the
/// next ancestor that can receive them.
mixin CollisionPassthrough on CollisionCallbacks {
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
