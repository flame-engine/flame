import 'dart:math';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class RevoluteJointExample extends Forge2DGame {
  static const description = '''
    In this example we use a joint to keep a body with several fixtures stuck
    to another body.

    Tap the screen to add more of these combined bodies.
  ''';

  RevoluteJointExample()
      : super(gravity: Vector2(0, 10.0), world: RevoluteJointWorld());
}

class RevoluteJointWorld extends Forge2DWorld
    with TapCallbacks, HasGameReference<Forge2DGame> {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    addAll(createBoundaries(game));
  }

  @override
  void onTapDown(TapDownEvent info) {
    super.onTapDown(info);
    final ball = Ball(info.localPosition);
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
