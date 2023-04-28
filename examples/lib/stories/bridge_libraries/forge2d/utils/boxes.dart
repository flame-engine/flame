import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class Box extends BodyComponent {
  final Vector2 startPosition;
  final double width;
  final double height;
  final BodyType bodyType;

  Box({
    required this.startPosition,
    required this.width,
    required this.height,
    this.bodyType = BodyType.dynamic,
  });

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(width / 2, height / 2, Vector2.zero(), 0);
    final fixtureDef = FixtureDef(shape, friction: 0.3, density: 10);
    final bodyDef = BodyDef(
      userData: this, // To be able to determine object in collision
      position: startPosition,
      type: bodyType,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class DraggableBox extends Box with Draggable {
  MouseJoint? mouseJoint;
  late final groundBody = world.createBody(BodyDef());

  DraggableBox({
    required super.startPosition,
    required super.width,
    required super.height,
  });

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    final mouseJointDef = MouseJointDef()
      ..maxForce = 3000 * body.mass * 10
      ..dampingRatio = 0
      ..frequencyHz = 20
      ..target.setFrom(info.eventPosition.game)
      ..collideConnected = false
      ..bodyA = groundBody
      ..bodyB = body;

    if (mouseJoint == null) {
      mouseJoint = MouseJoint(mouseJointDef);
      world.createJoint(mouseJoint!);
    }

    mouseJoint?.setTarget(info.eventPosition.game);
    return false;
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    if (mouseJoint == null) {
      return true;
    }
    world.destroyJoint(mouseJoint!);
    mouseJoint = null;
    return false;
  }
}
