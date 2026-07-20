import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/joint_renderer.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class Box extends BodyComponent with GlowingBody {
  final Vector2 startPosition;
  final double width;
  final double height;
  final BodyType bodyType;

  Box({
    required this.startPosition,
    required this.width,
    required this.height,
    this.bodyType = BodyType.dynamic,
    Color? color,
  }) {
    paint = Paint()..color = color ?? randomColor();
  }

  static int _colorIndex = 0;

  Color randomColor() =>
      ExampleColors.dynamicColor(_colorIndex++ % ExampleColors.dynamics.length);

  Paint randomPaint() => Paint()..color = randomColor();

  @override
  Body createBody() {
    final shapeDef = ShapeDef(
      material: SurfaceMaterial(restitution: 0.1),
      density: 10,
      enableContactEvents: true,
    );
    final bodyDef = BodyDef(
      userData: this, // To be able to determine object in collision
      position: startPosition,
      type: bodyType,
    );

    return world.createBody(bodyDef)
      ..createShape(Polygon.box(width / 2, height / 2), shapeDef);
  }
}

class DraggableBox extends Box with DragCallbacks {
  MouseJoint? mouseJoint;
  MouseJointRenderer? _jointRenderer;
  late final groundBody = world.createBody(BodyDef());
  bool _destroyJoint = false;

  DraggableBox({
    required super.startPosition,
    required super.width,
    required super.height,
  });

  @override
  void update(double dt) {
    if (_destroyJoint && mouseJoint != null) {
      mouseJoint!.destroy();
      mouseJoint = null;
      _jointRenderer?.removeFromParent();
      _jointRenderer = null;
      _destroyJoint = false;
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    final target = game.screenToWorld(event.devicePosition);

    final joint = world.physicsWorld.createMouseJoint(
      MouseJointDef(
        bodyA: groundBody,
        bodyB: body,
        target: target,
        maxForce: 5000 * body.mass,
        dampingRatio: 0.1,
        hertz: 50,
      ),
    );
    mouseJoint = joint;
    // Show the spring that drags the box towards the pointer.
    _jointRenderer = MouseJointRenderer(
      joint: joint,
      color: ExampleColors.amber,
    );
    world.add(_jointRenderer!);
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    mouseJoint?.target = game.screenToWorld(event.deviceEndPosition);

    return false;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    if (mouseJoint == null) {
      return;
    }

    _destroyJoint = true;
    event.continuePropagation = false;
  }
}
