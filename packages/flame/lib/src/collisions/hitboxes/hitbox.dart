import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';

/// The [Hitbox] is the default building block to determine whether two objects
/// have collided with each other. [ShapeHitbox] is the default implementation
/// used in FCS.
abstract class Hitbox<T extends Hitbox<T>>
    implements GenericCollisionCallbacks<T> {
  /// Whether the hitbox should:
  ///   * [CollisionType.active] - actively collide with other hitboxes.
  ///   * [CollisionType.passive] - passively collide with other hitboxes (only
  ///   collide with hitboxes that are active, but not other passive ones).
  ///   * [CollisionType.inactive] - not collide with any other hitboxes.
  CollisionType get collisionType;

  /// The axis-aligned bounding box of the [Hitbox], this is used to make a
  /// rough estimation of whether two hitboxes can possibly collide or not.
  Aabb2 get aabb;

  /// Whether the hitbox is solid or hollow.
  ///
  /// If it is solid, intersections will occur even if the other component is
  /// fully enclosed by the other hitbox. The intersection point in such cases
  /// will be the center of the enclosed [Hitbox].
  /// A hollow shape that is fully enclosed by a solid hitbox will cause an
  /// intersection result, but not the other way around.
  bool get isSolid;

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
