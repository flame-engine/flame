import 'dart:math';

import 'package:examples/stories/bridge_libraries/forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/forge2d/utils/boundaries.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class JointExample extends Forge2DGame with TapDetector {
  static const description = '''
    In this example we use a joint to keep a body with several fixtures stuck
    to another body.
    
    Tap the screen to add more of these combined bodies.
  ''';

  JointExample() : super(gravity: Vector2(0, 10.0));

  @override
  Future<void> onLoad() async {
    addAll(createBoundaries(this));
  }

  @override
  void onTapDown(TapDownInfo details) {
    super.onTapDown(details);
    final ball = Ball(details.eventPosition.game);
    add(ball);
    add(CircleShuffler(ball));
  }
}

class CircleShuffler extends BodyComponent {
  final Ball ball;

  CircleShuffler(this.ball);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: ball.body.position.clone(),
    );
    const numPieces = 5;
    const radius = 6.0;
    final body = world.createBody(bodyDef);

    for (var i = 0; i < numPieces; i++) {
      final xPos = radius * cos(2 * pi * (i / numPieces));
      final yPos = radius * sin(2 * pi * (i / numPieces));

      final shape = CircleShape()
        ..radius = 1.2
        ..position.setValues(xPos, yPos);

      final fixtureDef = FixtureDef(
        shape,
        density: 50.0,
        friction: 0.1,
        restitution: 0.9,
      );

      body.createFixture(fixtureDef);
    }

    final jointDef = RevoluteJointDef()
      ..initialize(body, ball.body, body.position);
    world.createJoint(RevoluteJoint(jointDef));

    return body;
  }
}
