import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
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
    Color? color,
  }) {
    if (color != null) {
      paint = PaletteEntry(color).paint();
    } else {
      paint = randomPaint();
    }
  }

  Paint randomPaint() => PaintExtension.random(withAlpha: 0.9, base: 100);

  @override
  Body createBody() {
    final shapeDef = ShapeDef(
      material: SurfaceMaterial(friction: 0.3, restitution: 0.2),
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
      _destroyJoint = false;
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    final target = game.screenToWorld(event.devicePosition);

    mouseJoint = world.physicsWorld.createMouseJoint(
      MouseJointDef(
        bodyA: groundBody,
        bodyB: body,
        target: target,
        maxForce: 5000 * body.mass,
        dampingRatio: 0.1,
        hertz: 50,
      ),
    );
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
