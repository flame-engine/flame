import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

/// {@template screen_collision_behavior}
/// A [CollisionBehavior] that fires only when the [Parent] entity collides
/// with a [ScreenHitbox].
///
/// This is a thin specialisation of [CollisionBehavior] that pins the
/// `Collider` type parameter to [ScreenHitbox] and exposes screen-specific
/// callbacks that drop the redundant `other` argument (which is always the
/// [ScreenHitbox]).
///
/// Subclass it to react when an entity touches the bounds of the screen,
/// e.g. to clamp its position, bounce, or remove it from the world.
///
/// ```dart
/// class BounceOffScreen extends ScreenCollisionBehavior<MyEntity> {
///   @override
///   void onScreenCollisionStart(Set<Vector2> intersectionPoints) {
///     parent.velocity.negate();
///   }
/// }
/// ```
///
/// Adding the behavior still requires the entity to host a
/// [PropagatingCollisionBehavior] and the game to use a [ScreenHitbox] for
/// the screen edges.
/// {@endtemplate}
abstract class ScreenCollisionBehavior<Parent extends EntityMixin>
    extends CollisionBehavior<ScreenHitbox, Parent> {
  /// {@macro screen_collision_behavior}
  ScreenCollisionBehavior({super.children, super.priority, super.key});

  /// Called every tick the entity is overlapping the screen edge.
  void onScreenCollision(Set<Vector2> intersectionPoints) {}

  /// Called the first frame the entity starts overlapping the screen edge.
  void onScreenCollisionStart(Set<Vector2> intersectionPoints) {}

  /// Called the first frame the entity stops overlapping the screen edge.
  void onScreenCollisionEnd() {}

  @override
  void onCollision(Set<Vector2> intersectionPoints, ScreenHitbox other) {
    onScreenCollision(intersectionPoints);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, ScreenHitbox other) {
    onScreenCollisionStart(intersectionPoints);
  }

  @override
  void onCollisionEnd(ScreenHitbox other) {
    onScreenCollisionEnd();
  }
}
