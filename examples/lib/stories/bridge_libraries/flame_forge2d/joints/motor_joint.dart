import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boxes.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class MotorJointExample extends Forge2DGame with TapDetector {
  static const description = '''
    This example shows how to use a `MotorJoint`. The ball spins around the 
    center point. Tap the screen to change the direction.
  ''';

  late Ball ball;
  late MotorJoint joint;
  final motorSpeed = 1;

  bool clockWise = true;

  MotorJointExample() : super(gravity: Vector2.zero());

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final box = Box(
      startPosition: Vector2.zero(),
      width: 2,
      height: 1,
      bodyType: BodyType.static,
    );
    world.add(box);

    ball = Ball(Vector2(0, -5));
    world.add(ball);

    await Future.wait([ball.loaded, box.loaded]);

    joint = createJoint(ball.body, box.body);
    world.add(JointRenderer(joint: joint));
  }

  @override
  Future<void> onTapDown(TapDownInfo info) async {
    super.onTapDown(info);
    clockWise = !clockWise;
  }

  MotorJoint createJoint(Body first, Body second) {
    final motorJointDef = MotorJointDef()
      ..initialize(first, second)
      ..maxForce = 1000
      ..maxTorque = 1000
      ..correctionFactor = 0.1;

    final joint = MotorJoint(motorJointDef);
    world.createJoint(joint);
    return joint;
  }

  final linearOffset = Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);

    var deltaOffset = motorSpeed * dt;
    if (clockWise) {
      deltaOffset = -deltaOffset;
    }

    final linearOffsetX = joint.getLinearOffset().x + deltaOffset;
    final linearOffsetY = joint.getLinearOffset().y + deltaOffset;
    linearOffset.setValues(linearOffsetX, linearOffsetY);
    final angularOffset = joint.getAngularOffset() + deltaOffset;

    joint.setLinearOffset(linearOffset);
    joint.setAngularOffset(angularOffset);
  }
}

class JointRenderer extends Component {
  JointRenderer({required this.joint});

  final MotorJoint joint;

  @override
  void render(Canvas canvas) {
    canvas.drawLine(
      joint.anchorA.toOffset(),
      joint.anchorB.toOffset(),
      debugPaint,
    );
  }
}
