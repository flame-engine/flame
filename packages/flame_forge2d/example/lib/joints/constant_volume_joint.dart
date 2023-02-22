import 'dart:math';

import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d_example/utils/ball.dart';
import 'package:flame_forge2d_example/utils/walls.dart';

class ConstantVolumeJointExample extends Forge2DGame with TapDetector {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    addAll(createBoundaries(this));
  }

  @override
  Future<void> onTapDown(TapDownInfo details) async {
    super.onTapDown(details);
    final tap = details.eventPosition.game;

    const numPieces = 20;
    const radius = 5.0;
    final center = tap;
    final balls = <Ball>[];

    for (var i = 0; i < numPieces; i++) {
      final xPos = radius * cos(2 * pi * (i / numPieces));
      final yPos = radius * sin(2 * pi * (i / numPieces));

      final ball = Ball(Vector2(xPos + center.x, yPos + center.y), radius: 0.5);

      add(ball);
      balls.add(ball);
    }

    await Future.wait(balls.map((e) => e.loaded));

    createJoint(balls);
  }

  void createJoint(List<Ball> balls) {
    final constantVolumeJoint = ConstantVolumeJointDef()
      ..frequencyHz = 10
      ..dampingRatio = 0.8;

    balls.forEach((ball) {
      constantVolumeJoint.addBody(ball.body);
    });

    world.createJoint(ConstantVolumeJoint(world, constantVolumeJoint));
  }
}
