import 'dart:math';

import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:forge2d/forge2d.dart';
import 'package:flame/gestures.dart';
import 'package:flame_forge2d/forge2d_game.dart';

import 'balls.dart';
import 'boundaries.dart';

class CircleShuffler extends BodyComponent {
  final Vector2 _center;

  CircleShuffler(this._center);

  @override
  Body createBody() {
    var bd = BodyDef()
      ..type = BodyType.dynamic
      ..position = _center + Vector2(0.0, -25.0);
    double numPieces = 5;
    double radius = 6.0;
    var body = world.createBody(bd);

    for (int i = 0; i < numPieces; i++) {
      double xPos = radius * cos(2 * pi * (i / numPieces));
      double yPos = radius * sin(2 * pi * (i / numPieces));

      var shape = CircleShape()
        ..radius = 1.2
        ..position.setValues(xPos, yPos);

      final fixtureDef = FixtureDef(shape)
        ..density = 50.0
        ..friction = .1
        ..restitution = .9;

      body.createFixture(fixtureDef);
    }
    // Create an empty ground body.
    var bodyDef = BodyDef();
    var groundBody = world.createBody(bodyDef);

    RevoluteJointDef rjd = RevoluteJointDef()
      ..initialize(body, groundBody, body.position)
      ..motorSpeed = pi
      ..maxMotorTorque = 1000000.0
      ..enableMotor = true;

    world.createJoint(rjd);
    return body;
  }
}

class CornerRamp extends BodyComponent {
  final bool isMirrored;
  final Vector2 _center;

  CornerRamp(this._center, {this.isMirrored = false});

  @override
  Body createBody() {
    final ChainShape shape = ChainShape();
    final int mirrorFactor = isMirrored ? -1 : 1;
    final double diff = 2.0 * mirrorFactor;
    List<Vector2> vertices = [
      Vector2(diff, 0),
      Vector2(diff + 20.0 * mirrorFactor, 20.0),
      Vector2(diff + 35.0 * mirrorFactor, 30.0),
    ];
    shape.createLoop(vertices);

    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.0
      ..friction = 0.1;

    final bodyDef = BodyDef()
      ..position = _center
      ..type = BodyType.static;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class CircleStressSample extends Forge2DGame with TapDetector {
  CircleStressSample() : super(gravity: Vector2(0, -10.0));

  Future<void> onLoad() async {
    await super.onLoad();
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
    final center = screenToWorld(viewport.effectiveSize / 2);
    add(CircleShuffler(center));
    add(CornerRamp(center, isMirrored: true));
    add(CornerRamp(center, isMirrored: false));
  }

  @override
  void onTapDown(TapDownInfo details) {
    super.onTapDown(details);
    final Vector2 tapPosition = details.eventPosition.game;
    final Random random = Random();
    List.generate(15, (i) {
      final Vector2 randomVector =
          (Vector2.random() - Vector2.all(-0.5)).normalized();
      add(Ball(tapPosition + randomVector, radius: random.nextDouble()));
    });
  }
}
