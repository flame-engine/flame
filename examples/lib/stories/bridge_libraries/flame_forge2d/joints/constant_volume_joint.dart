import 'dart:math';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class ConstantVolumeJointExample extends Forge2DGame {
  static const description = '''
    This example shows how to use a `ConstantVolumeJoint`. Tap the screen to add 
    a bunch off balls, that maintain a constant volume within them.
  ''';

  ConstantVolumeJointExample() : super(world: SpriteBodyWorld());
}

class SpriteBodyWorld extends Forge2DWorld
    with TapCallbacks, HasGameReference<Forge2DGame> {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    addAll(createBoundaries(game));
  }

  @override
  Future<void> onTapDown(TapDownEvent info) async {
    super.onTapDown(info);
    final center = info.localPosition;

    const numPieces = 20;
    const radius = 5.0;
    final balls = <Ball>[];

    for (var i = 0; i < numPieces; i++) {
      final x = radius * cos(2 * pi * (i / numPieces));
      final y = radius * sin(2 * pi * (i / numPieces));

      final ball = Ball(Vector2(x + center.x, y + center.y), radius: 0.5);

      add(ball);
      balls.add(ball);
    }

    await Future.wait(balls.map((e) => e.loaded));

    final constantVolumeJoint = ConstantVolumeJointDef()
      ..frequencyHz = 10
      ..dampingRatio = 0.8;

    balls.forEach((ball) {
      constantVolumeJoint.addBody(ball.body);
    });

    createJoint(
      ConstantVolumeJoint(
        physicsWorld,
        constantVolumeJoint,
      ),
    );
  }
}
