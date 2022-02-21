import '../../../collision_detection.dart';
import '../../../extensions.dart';

/// The [Hitbox] is the default building block to determine whether two objects
/// have collided with each other. [HitboxShape] is the default implementation
/// used in FCS.
mixin Hitbox<T extends Hitbox<T>> implements GenericCollisionCallbacks<T> {
  /// Whether the hitbox should:
  ///   * [CollidableType.active] - actively collide with other hitboxes.
  ///   * [CollidableType.passive] - passively collide with other hitboxes (only
  ///   collide with hitboxes that are active, but not other passive ones).
  ///   * [CollidableType.inactive] - not collide with any other hitboxes.
  CollidableType get collidableType;

  /// The axis-aligned bounding box of the [Hitbox], this is used to make a
  /// rough estimation of whether two hitboxes can possibly collide or not.
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
