import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boxes.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/joint_renderer.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class MotorJointExample extends Forge2DExampleGame {
  static const description = '''
    This example shows how to use a `MotorJoint`. The ball spins around the 
    center point. Tap the screen to change the direction.
  ''';

  MotorJointExample()
    : super(gravity: Vector2.zero(), world: MotorJointWorld());
}

class MotorJointWorld extends Forge2DWorld with TapCallbacks {
  late Ball ball;
  late MotorJoint joint;
  final motorSpeed = 1;

  bool clockWise = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final box = Box(
      startPosition: Vector2.zero(),
      width: 2,
      height: 1,
      bodyType: BodyType.static,
      color: ExampleColors.slate,
    );
    add(box);

    ball = Ball(Vector2(0, -5), color: ExampleColors.violet);
    add(ball);

    await Future.wait([ball.loaded, box.loaded]);

    joint = createMotorJoint(ball.body, box.body);
    add(JointRenderer(joint: joint));
  }

  @override
  void onTapDown(TapDownEvent info) {
    super.onTapDown(info);
    clockWise = !clockWise;
  }

  MotorJoint createMotorJoint(Body first, Body second) {
    return physicsWorld.createMotorJoint(
      MotorJointDef(
        bodyA: first,
        bodyB: second,
        // The target offset of the box in the ball's frame. Starting with
        // the current offset keeps the bodies where they are, and update
        // below drifts it from there.
        linearOffset: first.localPoint(second.position),
        maxForce: 1000,
        maxTorque: 1000,
        correctionFactor: 0.1,
      ),
    );
  }

  final linearOffset = Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);

    var deltaOffset = motorSpeed * dt;
    if (clockWise) {
      deltaOffset = -deltaOffset;
    }

    final linearOffsetX = joint.linearOffset.x + deltaOffset;
    final linearOffsetY = joint.linearOffset.y + deltaOffset;
    linearOffset.setValues(linearOffsetX, linearOffsetY);
    final angularOffset = joint.angularOffset + deltaOffset;

    joint.linearOffset = linearOffset;
    joint.angularOffset = angularOffset;
  }
}
