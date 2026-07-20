import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boxes.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class PrismaticJointExample extends Forge2DGame {
  static const description = '''
    This example shows how to use a `PrismaticJoint`. 
    
    Drag the box along the specified axis, bound between lower and upper limits.
    Also, there's a motor enabled that's pulling the box to the lower limit.
  ''';

  final Vector2 anchor = Vector2.zero();
  final Vector2 axis = Vector2(1, 0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final box = DraggableBox(startPosition: anchor, width: 6, height: 6);
    world.add(box);
    await Future.wait([box.loaded]);

    final joint = createJoint(box.body, anchor);
    world.add(JointRenderer(joint: joint, anchor: anchor, axis: axis));
  }

  PrismaticJoint createJoint(Body box, Vector2 anchor) {
    final groundBody = world.createBody(BodyDef());

    return world.physicsWorld.createPrismaticJoint(
      PrismaticJointDef(
        bodyA: box,
        bodyB: groundBody,
        localAxisA: axis,
        enableLimit: true,
        lowerTranslation: -20,
        upperTranslation: 20,
        enableMotor: true,
        motorSpeed: 1,
        maxMotorForce: 100,
      ),
    );
  }
}

class JointRenderer extends Component {
  JointRenderer({
    required this.joint,
    required this.anchor,
    required this.axis,
  });

  final PrismaticJoint joint;
  final Vector2 anchor;
  final Vector2 axis;
  final Vector2 p1 = Vector2.zero();
  final Vector2 p2 = Vector2.zero();

  @override
  void render(Canvas canvas) {
    p1
      ..setFrom(axis)
      ..scale(joint.lowerLimit)
      ..add(anchor);
    p2
      ..setFrom(axis)
      ..scale(joint.upperLimit)
      ..add(anchor);

    canvas.drawLine(p1.toOffset(), p2.toOffset(), debugPaint);
  }
}
