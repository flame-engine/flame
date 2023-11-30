import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boxes.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class GearJointExample extends Forge2DGame {
  static const description = '''
    This example shows how to use a `GearJoint`. 
        
    Drag the box along the specified axis and observe gears respond to the 
    translation.
  ''';

  GearJointExample() : super(world: GearJointWorld());
}

class GearJointWorld extends Forge2DWorld with HasGameReference<Forge2DGame> {
  late PrismaticJoint prismaticJoint;
  Vector2 boxAnchor = Vector2.zero();

  double boxWidth = 2;
  double ball1Radius = 4;
  double ball2Radius = 2;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final box =
        DraggableBox(startPosition: boxAnchor, width: boxWidth, height: 20);
    add(box);

    final ball1Anchor = boxAnchor - Vector2(boxWidth / 2 + ball1Radius, 0);
    final ball1 = Ball(ball1Anchor, radius: ball1Radius);
    add(ball1);

    final ball2Anchor = ball1Anchor - Vector2(ball1Radius + ball2Radius, 0);
    final ball2 = Ball(ball2Anchor, radius: ball2Radius);
    add(ball2);

    await Future.wait([box.loaded, ball1.loaded, ball2.loaded]);

    prismaticJoint = createPrismaticJoint(box.body, boxAnchor);
    final revoluteJoint1 = createRevoluteJoint(ball1.body, ball1Anchor);
    final revoluteJoint2 = createRevoluteJoint(ball2.body, ball2Anchor);

    createGearJoint(prismaticJoint, revoluteJoint1, 1);
    createGearJoint(revoluteJoint1, revoluteJoint2, 0.5);
    add(JointRenderer(joint: prismaticJoint, anchor: boxAnchor));
  }

  PrismaticJoint createPrismaticJoint(Body box, Vector2 anchor) {
    final groundBody = createBody(BodyDef());

    final prismaticJointDef = PrismaticJointDef()
      ..initialize(
        groundBody,
        box,
        anchor,
        Vector2(0, 1),
      )
      ..enableLimit = true
      ..lowerTranslation = -10
      ..upperTranslation = 10;

    final joint = PrismaticJoint(prismaticJointDef);
    createJoint(joint);
    return joint;
  }

  RevoluteJoint createRevoluteJoint(Body ball, Vector2 anchor) {
    final groundBody = createBody(BodyDef());

    final revoluteJointDef = RevoluteJointDef()
      ..initialize(
        groundBody,
        ball,
        anchor,
      );

    final joint = RevoluteJoint(revoluteJointDef);
    createJoint(joint);
    return joint;
  }

  void createGearJoint(Joint first, Joint second, double gearRatio) {
    final gearJointDef = GearJointDef()
      ..bodyA = first.bodyA
      ..bodyB = second.bodyA
      ..joint1 = first
      ..joint2 = second
      ..ratio = gearRatio;

    final joint = GearJoint(gearJointDef);
    createJoint(joint);
  }
}

class JointRenderer extends Component {
  JointRenderer({required this.joint, required this.anchor});

  final PrismaticJoint joint;
  final Vector2 anchor;
  final Vector2 p1 = Vector2.zero();
  final Vector2 p2 = Vector2.zero();

  @override
  void render(Canvas canvas) {
    p1
      ..setFrom(joint.getLocalAxisA())
      ..scale(joint.getLowerLimit())
      ..add(anchor);
    p2
      ..setFrom(joint.getLocalAxisA())
      ..scale(joint.getUpperLimit())
      ..add(anchor);

    canvas.drawLine(p1.toOffset(), p2.toOffset(), debugPaint);
  }
}
