import 'dart:math';
import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class RevoluteJointWithMotorExample extends Forge2DExampleGame {
  static const String description = '''
    This example showcases a revolute joint, which is the spinning balls in the
    center.
    
    If you tap the screen some colorful balls are added and will
    interact with the bodies tied to the revolute joint once they have fallen
    down the funnel.
  ''';

  RevoluteJointWithMotorExample() : super(world: RevoluteJointWithMotorWorld());
}

class RevoluteJointWithMotorWorld extends Forge2DWorld
    with TapCallbacks, HasGameReference<Forge2DGame> {
  final random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final boundaries = createBoundaries(game);
    addAll(boundaries);
    final center = Vector2.zero();
    add(CircleShuffler(center));
    add(CornerRamp(center, isMirrored: true));
    add(CornerRamp(center));
  }

  @override
  void onTapDown(TapDownEvent info) {
    super.onTapDown(info);
    final tapPosition = info.localPosition;
    List.generate(15, (i) {
      final randomVector = (Vector2.random() - Vector2.all(0.5)).normalized();
      add(Ball(tapPosition + randomVector, radius: random.nextDouble()));
    });
  }
}

class CircleShuffler extends BodyComponent {
  CircleShuffler(this._center);

  final Vector2 _center;

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: _center + Vector2(0.0, 25.0),
    );
    const numPieces = 5;
    const radius = 6.0;
    final body = world.createBody(bodyDef);

    for (var i = 0; i < numPieces; i++) {
      final xPos = radius * cos(2 * pi * (i / numPieces));
      final yPos = radius * sin(2 * pi * (i / numPieces));

      body.createShape(
        Circle(radius: 1.2, center: Vector2(xPos, yPos)),
        ShapeDef(
          density: 50.0,
          material: SurfaceMaterial(friction: 0.5, restitution: 0.4),
        ),
      );
    }
    // Create an empty ground body.
    final groundBody = world.createBody(BodyDef());

    world.physicsWorld.createRevoluteJoint(
      RevoluteJointDef(
        bodyA: body,
        bodyB: groundBody,
        localAnchorB: body.position.clone(),
        motorSpeed: pi,
        maxMotorTorque: 1000000.0,
        enableMotor: true,
      ),
    );
    return body;
  }
}

class CornerRamp extends BodyComponent with GlowingBody {
  CornerRamp(this._center, {this.isMirrored = false}) {
    paint = Paint()..color = ExampleColors.slate;
  }

  final bool isMirrored;
  final Vector2 _center;

  @override
  Body createBody() {
    final mirrorFactor = isMirrored ? -1 : 1;
    final diff = 2.0 * mirrorFactor;
    // A solid polygon rather than a chain loop: chains are one-sided in
    // Box2D v3, so a chain ramp lets balls through from the other side and
    // they end up trapped inside it.
    final vertices = [
      Vector2(diff, 0),
      Vector2(diff + 20.0 * mirrorFactor, -20.0),
      Vector2(diff + 35.0 * mirrorFactor, -30.0),
    ];

    final bodyDef = BodyDef(position: _center);

    return world.createBody(bodyDef)..createShape(
      Polygon(vertices),
      ShapeDef(material: SurfaceMaterial(friction: 0.5)),
    );
  }
}
