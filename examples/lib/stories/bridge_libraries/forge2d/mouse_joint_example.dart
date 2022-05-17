import 'package:examples/stories/bridge_libraries/forge2d/revolute_joint_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/forge2d/utils/boundaries.dart';
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
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);

    final center = screenToWorld(camera.viewport.effectiveSize / 2);
    groundBody = world.createBody(BodyDef());
    ball = Ball(center, radius: 5);
    add(ball);
    add(CornerRamp(center));
    add(CornerRamp(center, isMirrored: true));
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo details) {
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

    mouseJoint?.setTarget(details.eventPosition.game);
    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo details) {
    if (mouseJoint == null) {
      return true;
    }
    world.destroyJoint(mouseJoint!);
    mouseJoint = null;
    return false;
  }
}
