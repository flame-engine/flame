import 'package:ember_quest/ember_quest.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class PlatformBlock extends SpriteComponent with HasGameRef<EmberQuestGame> {
  late Vector2 _gridPosition;
  late double _xPositionOffset;
  PlatformBlock({
    required Vector2 gridPosition,
    required double xPositionOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft) {
    _gridPosition = gridPosition;
    _xPositionOffset = xPositionOffset;
  }

  @override
  Future<void> onLoad() async {
    final platformImage = gameRef.images.fromCache('block.png');
    sprite = Sprite(platformImage);
    position = Vector2((_gridPosition.x * size.x) + _xPositionOffset,
        gameRef.size.y - (_gridPosition.y * size.y));
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    Vector2 velocity = Vector2(gameRef.objectSpeed, 0);
    position += velocity * dt;
    if (position.x < -size.x || gameRef.health <= 0) {
      removeFromParent();
    }
    super.update(dt);
  }
}
