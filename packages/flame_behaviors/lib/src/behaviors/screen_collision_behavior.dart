import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

/// {@template screen_collision_behavior}
/// A [CollisionBehavior] that fires only when the [Parent] entity collides
/// with a [ScreenHitbox].
///
/// Pins the `Collider` type parameter of [CollisionBehavior] to
/// [ScreenHitbox] so subclasses only have to specify their parent entity
/// type. Override the standard [onCollision], [onCollisionStart], and
/// [onCollisionEnd] callbacks (now strongly typed to receive a
/// [ScreenHitbox]) to react to screen-edge interactions — for example to
/// clamp the entity's position, bounce off the edge, or wrap to the
/// opposite side using the [ScreenHitbox]'s `position` and `scaledSize`.
///
/// ```dart
/// class WrapAroundScreen extends ScreenCollisionBehavior<MyEntity> {
///   @override
///   void onCollisionEnd(ScreenHitbox screen) {
///     if (parent.position.x > screen.position.x + screen.scaledSize.x) {
///       parent.position.x = screen.position.x;
///     }
///   }
/// }
/// ```
///
/// Adding the behavior still requires the entity to host a
/// [PropagatingCollisionBehavior] and the game to register a
/// [ScreenHitbox] for the screen edges.
/// {@endtemplate}
abstract class ScreenCollisionBehavior<Parent extends EntityMixin>
    extends CollisionBehavior<ScreenHitbox, Parent> {
  /// {@macro screen_collision_behavior}
  ScreenCollisionBehavior({super.children, super.priority, super.key});
}
