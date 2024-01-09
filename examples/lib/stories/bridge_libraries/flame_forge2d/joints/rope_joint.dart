import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boxes.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class RopeJointExample extends Forge2DGame {
  static const description = '''
    This example shows how to use a `RopeJoint`. 
    
    Drag the box handle along the axis and observe the rope respond to the 
    movement.
  ''';

  RopeJointExample() : super(world: RopeJointWorld());
}

class RopeJointWorld extends Forge2DWorld
    with DragCallbacks, HasGameReference<Forge2DGame> {
  double handleWidth = 6;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final handleBody = await createHandle();
    createRope(handleBody);
  }

  Future<Body> createHandle() async {
    final anchor = game.screenToWorld(Vector2(0, 100))..x = 0;

    final box = DraggableBox(
      startPosition: anchor,
      width: handleWidth,
      height: 3,
    );
    await add(box);

    createPrismaticJoint(box.body, anchor);
    return box.body;
  }

  Future<void> createRope(Body handle) async {
    const length = 50;
    var prevBody = handle;

    for (var i = 0; i < length; i++) {
      final newPosition = prevBody.worldCenter + Vector2(0, 1);
      final ball = Ball(newPosition, radius: 0.5, color: Colors.white);
      await add(ball);

      createRopeJoint(ball.body, prevBody);
      prevBody = ball.body;
    }
  }

  void createPrismaticJoint(Body box, Vector2 anchor) {
    final groundBody = createBody(BodyDef());
    final halfWidth = game.screenToWorld(Vector2.zero()).x.abs();

    final prismaticJointDef = PrismaticJointDef()
      ..initialize(
        box,
        groundBody,
        anchor,
        Vector2(1, 0),
      )
      ..enableLimit = true
      ..lowerTranslation = -halfWidth + handleWidth / 2
      ..upperTranslation = halfWidth - handleWidth / 2;

    final joint = PrismaticJoint(prismaticJointDef);
    createJoint(joint);
  }

  void createRopeJoint(Body first, Body second) {
    final ropeJointDef = RopeJointDef()
      ..bodyA = first
      ..localAnchorA.setFrom(first.getLocalCenter())
      ..bodyB = second
      ..localAnchorB.setFrom(second.getLocalCenter())
      ..maxLength = (second.worldCenter - first.worldCenter).length;

    createJoint(RopeJoint(ropeJointDef));
  }
}
