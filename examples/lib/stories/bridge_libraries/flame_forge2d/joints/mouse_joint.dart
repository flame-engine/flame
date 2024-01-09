import 'package:examples/stories/bridge_libraries/flame_forge2d/revolute_joint_with_motor_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class MouseJointExample extends Forge2DGame {
  static const description = '''
    In this example we use a `MouseJoint` to make the ball follow the mouse
    when you drag it around.
  ''';

  MouseJointExample()
      : super(gravity: Vector2(0, 10.0), world: MouseJointWorld());
}

class MouseJointWorld extends Forge2DWorld
    with DragCallbacks, HasGameReference<Forge2DGame> {
  late Ball ball;
  late Body groundBody;
  MouseJoint? mouseJoint;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final boundaries = createBoundaries(game);
    addAll(boundaries);

    final center = Vector2.zero();
    groundBody = createBody(BodyDef());
    ball = Ball(center, radius: 5);
    add(ball);
    add(CornerRamp(center));
    add(CornerRamp(center, isMirrored: true));
  }

  @override
  void onDragStart(DragStartEvent info) {
    super.onDragStart(info);
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
      createJoint(mouseJoint!);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent info) {
    mouseJoint?.setTarget(info.localEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent info) {
    super.onDragEnd(info);
    destroyJoint(mouseJoint!);
    mouseJoint = null;
  }
}
