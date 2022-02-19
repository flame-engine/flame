import '../../collision_detection.dart';
import '../../extensions.dart';

mixin Hitbox<T extends Hitbox<T>> implements GenericCollisionCallbacks<T> {
  CollidableType get collidableType;
  Aabb2 get aabb;

  /// Checks whether the [Hitbox] contains the [point].
  bool containsPoint(Vector2 point);

  /// Where this [Hitbox] has intersection points with another [Hitbox].
  Set<Vector2> intersections(T other);

  /// This should be a cheaper calculation than comparing the exact boundaries
  /// if the exact calculation is expensive.
  /// This method could for example check two [Rect]s or [Aabb2]s against each
  /// other.
  bool possiblyIntersects(T other);
}
