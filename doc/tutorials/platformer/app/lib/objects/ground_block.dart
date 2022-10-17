import 'package:EmberQuest/main.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class GroundBlock extends SpriteComponent
    with CollisionCallbacks, HasGameRef<EmberQuestGame> {
  late Vector2 _gridPosition;
  late int _segmentOffset;
  GroundBlock({
    required Vector2 gridPosition,
    required int segmentOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft) {
    _gridPosition = gridPosition;
    _segmentOffset = segmentOffset;
  }

  @override
  Future<void> onLoad() async {
    final groundImage = await gameRef.images.load('ground.png');
    sprite = Sprite(groundImage);
    position = Vector2(
        (_gridPosition.x * size.x) + (_segmentOffset * size.x * 10),
        gameRef.size.y - (_gridPosition.y * size.y));
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }
}
