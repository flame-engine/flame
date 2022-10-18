import 'package:EmberQuest/ember_quest.dart';
import 'package:EmberQuest/extensions/random.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class GroundBlock extends SpriteComponent
    with CollisionCallbacks, HasGameRef<EmberQuestGame> {
  late Vector2 _gridPosition;
  late double _xPositionOffset;

  GroundBlock({
    required Vector2 gridPosition,
    required double xPositionOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft) {
    _gridPosition = gridPosition;
    _xPositionOffset = xPositionOffset;
  }

  @override
  Future<void> onLoad() async {
    final groundImage = await gameRef.images.load('ground.png');
    sprite = Sprite(groundImage);
    position = Vector2((_gridPosition.x * size.x) + _xPositionOffset,
        gameRef.size.y - (_gridPosition.y * size.y));
    add(RectangleHitbox()..collisionType = CollisionType.passive);
    if (_gridPosition.x == 9 && position.x > gameRef.lastBlockXPosition) {
      gameRef.lastBlockXPosition = position.x + size.x;
    }
  }

  @override
  void update(double dt) {
    Vector2 velocity = Vector2(gameRef.objectSpeed, 0);
    position += velocity * dt;

    if (position.x < -64) {
      removeFromParent();
      if (_gridPosition.x == 0) {
        gameRef.loadGameSegments(
            random.fromRange(0, 4).toInt(), gameRef.lastBlockXPosition);
      }
    }
    if (_gridPosition.x == 9 && position.x > gameRef.lastBlockXPosition) {
      gameRef.lastBlockXPosition = position.x;
    }

    super.update(dt);
  }
}
