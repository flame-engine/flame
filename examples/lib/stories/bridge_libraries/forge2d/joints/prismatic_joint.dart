import 'dart:ui';

import 'package:examples/stories/bridge_libraries/forge2d/utils/boxes.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class PrismaticJointExample extends Forge2DGame
    with TapDetector, HasDraggables {
  static const description = '''
    This example shows how to use a `PrismaticJoint`. 
    
    Drag the box along the specified axis, bound between lower and upper limits.
    Also, there's a motor enabled that's pulling the box to the lower limit.
  ''';

  late PrismaticJoint joint;
  late Vector2 anchor = size / 2;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final box = DraggableBox(startPosition: anchor, width: 3, height: 3);
    add(box);
    await Future.wait([box.loaded]);

    createJoint(box.body, anchor);
  }

  void createJoint(Body box, Vector2 anchor) {
    final groundBody = world.createBody(BodyDef());

    final prismaticJointDef = PrismaticJointDef()
      ..initialize(
        box,
        groundBody,
        anchor,
        Vector2(1, 0),
      )
      ..enableLimit = true
      ..lowerTranslation = -20
      ..upperTranslation = 20
      ..enableMotor = true
      ..motorSpeed = 1
      ..maxMotorForce = 100;

    joint = PrismaticJoint(prismaticJointDef);
    world.createJoint(joint);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final p1 =
        worldToScreen(anchor + joint.getLocalAxisA() * joint.getLowerLimit());
    final p2 =
        worldToScreen(anchor + joint.getLocalAxisA() * joint.getUpperLimit());

    canvas.drawLine(p1.toOffset(), p2.toOffset(), debugPaint);
  }
}
