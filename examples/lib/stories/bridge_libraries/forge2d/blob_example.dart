import 'dart:math' as math;

import 'package:examples/stories/bridge_libraries/forge2d/utils/boundaries.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class BlobExample extends Forge2DGame with TapDetector {
  static const String description = '''
    In this example we show the power of joints by showing interactions between
    bodies tied together.
    
    Tap the screen to add boxes that will bounce on the "blob" in the center.
  ''';

  @override
  Future<void> onLoad() async {
    final worldCenter = screenToWorld(size * camera.zoom / 2);
    final blobCenter = worldCenter + Vector2(0, -30);
    final blobRadius = Vector2.all(6.0);
    addAll(createBoundaries(this));
    add(Ground(worldCenter));
    final jointDef = ConstantVolumeJointDef()
      ..frequencyHz = 20.0
      ..dampingRatio = 1.0
      ..collideConnected = false;

    await addAll([
      for (var i = 0; i < 20; i++) BlobPart(i, jointDef, blobRadius, blobCenter)
    ]);
    world.createJoint(ConstantVolumeJoint(world, jointDef));
  }

  @override
  void onTapDown(TapDownInfo details) {
    super.onTapDown(details);
    add(FallingBox(details.eventPosition.game));
  }
}

class Ground extends BodyComponent {
  final Vector2 worldCenter;

  Ground(this.worldCenter);

  @override
  Body createBody() {
    final shape = PolygonShape();
    shape.setAsBoxXY(20.0, 0.4);
    final fixtureDef = FixtureDef(shape, friction: 0.2);

    final bodyDef = BodyDef(position: worldCenter.clone());
    final ground = world.createBody(bodyDef);
    ground.createFixture(fixtureDef);

    shape.setAsBox(0.4, 20.0, Vector2(-10.0, 0.0), 0.0);
    ground.createFixture(fixtureDef);
    shape.setAsBox(0.4, 20.0, Vector2(10.0, 0.0), 0.0);
    ground.createFixture(fixtureDef);
    return ground;
  }
}

class BlobPart extends BodyComponent {
  final ConstantVolumeJointDef jointDef;
  final int bodyNumber;
  final Vector2 blobRadius;
  final Vector2 blobCenter;

  BlobPart(
    this.bodyNumber,
    this.jointDef,
    this.blobRadius,
    this.blobCenter,
  );

  @override
  Body createBody() {
    const nBodies = 20.0;
    const bodyRadius = 0.5;
    final angle = (bodyNumber / nBodies) * math.pi * 2;
    final x = blobCenter.x + blobRadius.x * math.sin(angle);
    final y = blobCenter.y + blobRadius.y * math.cos(angle);

    final bodyDef = BodyDef(
      fixedRotation: true,
      position: Vector2(x, y),
      type: BodyType.dynamic,
    );
    final body = world.createBody(bodyDef);

    final shape = CircleShape()..radius = bodyRadius;
    final fixtureDef = FixtureDef(
      shape,
      density: 1.0,
      friction: 0.2,
    );
    body.createFixture(fixtureDef);
    jointDef.addBody(body);
    return body;
  }
}

class FallingBox extends BodyComponent {
  final Vector2 position;

  FallingBox(this.position);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: position,
    );
    final shape = PolygonShape()..setAsBoxXY(2, 4);
    final body = world.createBody(bodyDef);
    body.createFixtureFromShape(shape, 1.0);
    return body;
  }
}
