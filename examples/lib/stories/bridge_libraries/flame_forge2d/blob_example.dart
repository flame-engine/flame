import 'dart:math' as math;

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class BlobExample extends Forge2DGame {
  static const String description = '''
    In this example we show the power of joints by showing interactions between
    bodies tied together.
    
    Tap the screen to add boxes that will bounce on the "blob" in the center.
  ''';
  BlobExample() : super(world: BlobWorld());
}

class BlobWorld extends Forge2DWorld
    with TapCallbacks, HasGameReference<Forge2DGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final blobCenter = Vector2(0, -30);
    final blobRadius = Vector2.all(6.0);
    addAll(createBoundaries(game));
    add(Ground(Vector2.zero()));
    final jointDef = ConstantVolumeJointDef()
      ..frequencyHz = 20.0
      ..dampingRatio = 1.0
      ..collideConnected = false;

    await addAll([
      for (var i = 0; i < 20; i++)
        BlobPart(i, jointDef, blobRadius, blobCenter),
    ]);
    createJoint(ConstantVolumeJoint(physicsWorld, jointDef));
  }

  @override
  void onTapDown(TapDownEvent info) {
    super.onTapDown(info);
    add(FallingBox(info.localPosition));
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
      friction: 0.2,
    );
    body.createFixture(fixtureDef);
    jointDef.addBody(body);
    return body;
  }
}

class FallingBox extends BodyComponent {
  final Vector2 _position;

  FallingBox(this._position);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: _position,
    );
    final shape = PolygonShape()..setAsBoxXY(2, 4);
    final body = world.createBody(bodyDef);
    body.createFixtureFromShape(shape);
    return body;
  }
}
