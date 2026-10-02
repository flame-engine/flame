import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:material_ui/material_ui.dart';

import '../ember_quest.dart';

class Star({
  required final Vector2 gridPosition,
  required var double xOffset,
}) extends SpriteComponent with HasGameRef<EmberQuestGame> {
  final Vector2 velocity = Vector2.zero();

  this : super(size: Vector2.all(64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final starImage = gameRef.images.fromCache('assets/images/star.png');
    sprite = Sprite(starImage);
    position = Vector2(
      (gridPosition.x * size.x) + xOffset + (size.x / 2),
      gameRef.size.y - (gridPosition.y * size.y) - (size.y / 2),
    );
    add(RectangleHitbox(collisionType: CollisionType.passive));
    add(
      SizeEffect.by(
        Vector2.all(-24),
        EffectController(
          duration: 0.75,
          reverseDuration: 0.5,
          infinite: true,
          curve: Curves.easeOut,
        ),
      ),
    );
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
