// ignore_for_file: deprecated_member_use

import 'package:examples/stories/bridge_libraries/flame_forge2d/revolute_joint_with_motor_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class MouseJointExample extends Forge2DGame with MultiTouchDragDetector {
  static const description = '''
    In this example we use a `MouseJoint` to make the ball follow the mouse
    when you drag it around.
  ''';

  MouseJointExample() : super(gravity: Vector2(0, 10.0));

  late Ball ball;
  late Body groundBody;
  MouseJoint? mouseJoint;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final boundaries = createBoundaries(this);
    world.addAll(boundaries);

    final center = Vector2.zero();
    groundBody = world.createBody(BodyDef());
    ball = Ball(center, radius: 5);
    world.add(ball);
    world.add(CornerRamp(center));
    world.add(CornerRamp(center, isMirrored: true));
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    final mouseJointDef = MouseJointDef()
      ..maxForce = 3000 * ball.body.mass * 10
      ..dampingRatio = 0.1
      ..frequencyHz = 5
      ..target.setFrom(ball.body.position)
      ..collideConnected = false
      ..bodyA = groundBody
      ..bodyB = ball.body;

    if (mouseJoint == null) {
      mouseJoint = MouseJoint(mouseJointDef);
      world.createJoint(mouseJoint!);
    }

    mouseJoint?.setTarget(screenToWorld(info.eventPosition.widget));
    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    if (mouseJoint == null) {
      return true;
    }
    world.destroyJoint(mouseJoint!);
    mouseJoint = null;
    return false;
  }
}
