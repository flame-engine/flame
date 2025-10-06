import 'package:flame/collisions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

/// Simplified "screen wrapping" behavior, while not perfect it does showcase
/// the possibility of acting on collision with non-entities.
class ScreenCollidingBehavior
    extends CollisionBehavior<ScreenHitbox, PositionedEntity> {
  @override
  void onCollisionEnd(ScreenHitbox other) {
    if (parent.position.x < other.position.x) {
      parent.position.x = other.position.x + other.scaledSize.x;
    } else if (parent.position.x > other.position.x + other.scaledSize.x) {
      parent.position.x = other.position.x;
    }

    if (parent.position.y < other.position.y) {
      parent.position.y = other.position.y + other.scaledSize.y;
    } else if (parent.position.y > other.position.y + other.scaledSize.y) {
      parent.position.y = other.position.y;
    }
  }
}
