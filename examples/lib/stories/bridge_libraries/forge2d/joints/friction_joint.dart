import 'package:examples/stories/bridge_libraries/forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/forge2d/utils/boundaries.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class FrictionJointExample extends Forge2DGame with TapDetector {
  late Wall slope;
  late Wall border;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final boundaries = createBoundaries(this);
    border = boundaries.first;
    addAll(boundaries);

    final slopeLeft = Vector2(size.x / 2 - 20, size.y / 2 - 10);
    final slopeRight = Vector2(size.x / 2 + 20, size.y / 2 + 10);
    slope = Wall(slopeLeft, slopeRight);
    add(slope);
  }

  @override
  Future<void> onTapDown(TapDownInfo details) async {
    super.onTapDown(details);
    final tap = details.eventPosition.game;

    final ball = Ball(tap);
    add(ball);

    await ball.loaded;

    createJoint(ball);
  }

  void createJoint(Ball ball) {
    final frictionJointDef = FrictionJointDef()
      ..initialize(ball.body, border.body, ball.body.worldCenter)
      ..maxForce = 50
      ..maxTorque = 50;

    world.createJoint(FrictionJoint(frictionJointDef));
  }
}
