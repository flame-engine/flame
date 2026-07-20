import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boxes.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/joint_renderer.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class PrismaticJointExample extends Forge2DExampleGame {
  static const description = '''
    This example shows how to use a `PrismaticJoint`.

    Drag the box along the specified axis, bound between lower and upper limits.
    Also, there's a motor enabled that's pulling the box to the lower limit.
    The line shows the axis between the two limits.
  ''';

  final Vector2 anchor = Vector2.zero();
  final Vector2 axis = Vector2(1, 0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final box = DraggableBox(
      startPosition: anchor,
      width: 6,
      height: 6,
    );
    world.add(box);
    await Future.wait([box.loaded]);

    final joint = createJoint(box.body, anchor);
    world.add(
      PrismaticJointRenderer(joint: joint, anchor: anchor, axis: axis),
    );
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
