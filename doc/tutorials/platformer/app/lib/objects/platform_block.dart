import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../ember_quest.dart';

class PlatformBlock({
  required final Vector2 gridPosition,
  required var double xOffset,
}) extends SpriteComponent with HasGameRef<EmberQuestGame> {
  final Vector2 velocity = Vector2.zero();

  this : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  Future<void> onLoad() async {
    final platformImage = gameRef.images.fromCache('assets/images/block.png');
    sprite = Sprite(platformImage);
    position = Vector2(
      (gridPosition.x * size.x) + xOffset,
      gameRef.size.y - (gridPosition.y * size.y),
    );
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    velocity.x = gameRef.objectSpeed;
    position += velocity * dt;
    if (position.x < -size.x || gameRef.health <= 0) {
      removeFromParent();
    }
    super.update(dt);
  }
}
