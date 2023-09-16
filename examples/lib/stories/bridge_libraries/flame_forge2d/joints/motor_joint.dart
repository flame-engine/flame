import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boxes.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class MotorJointExample extends Forge2DGame {
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
    super.onLoad();

    final box = Box(
      startPosition: Vector2.zero(),
      width: 2,
      height: 1,
      bodyType: BodyType.static,
    );
    add(box);

    ball = Ball(Vector2(0, -5));
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
    final motorJointDef = MotorJointDef()
      ..initialize(first, second)
      ..maxForce = 1000
      ..maxTorque = 1000
      ..correctionFactor = 0.1;

    final joint = MotorJoint(motorJointDef);
    createJoint(joint);
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
