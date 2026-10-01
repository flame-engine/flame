import 'package:crystal_ball/src/game/constants.dart';
import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Ground() extends Component {
  this : super(children: [Rectangle(kPlayerSize.y / 2)]) {
    rectangle = children.first as Rectangle;
  }

  late final Rectangle rectangle;
}

class Rectangle(double y)
    extends PositionComponent
    with CollisionCallbacks, ParentIsA<Ground>, HasGameRef<CrystalBallGame> {
  this
    : super(
        anchor: Anchor.topCenter,
        position: Vector2(0, y),
        size: Vector2(
          kCameraSize.x,
          kCameraSize.y / 2,
        ),
        children: [
          RectangleHitbox(
            size: Vector2(
              kCameraSize.x,
              kCameraSize.y / 2,
            ),
          ),
          RectangleHitbox(
            position: Vector2(0, kPlayerRadius),
            size: Vector2(
              kCameraSize.x,
              kCameraSize.y / 2,
            ),
          ),
          for (var i = 2; i < 30; i++)
            RectangleHitbox(
              position: Vector2(0, kPlayerRadius * i),
              size: Vector2(
                kCameraSize.x,
                kCameraSize.y / 2,
              ),
            ),
        ],
      );

  double get topEdge => absolutePositionOfAnchor(Anchor.topCenter).y;
}
