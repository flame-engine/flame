import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/joint_renderer.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class DistanceJointExample extends Forge2DExampleGame {
  static const description = '''
    This example shows how to use a `DistanceJoint`. Tap the screen to add a 
    pair of balls joined with a `DistanceJoint`.
  ''';

  DistanceJointExample() : super(world: DistanceJointWorld());
}

class DistanceJointWorld extends Forge2DWorld
    with TapCallbacks, HasGameReference<Forge2DGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    addAll(createBoundaries(game));
  }

  @override
  Future<void> onTapDown(TapDownEvent info) async {
    super.onTapDown(info);
    final tap = info.localPosition;

    final first = Ball(tap);
    final second = Ball(Vector2(tap.x + 3, tap.y + 3));
    addAll([first, second]);

    await Future.wait([first.loaded, second.loaded]);

    final joint = physicsWorld.createDistanceJoint(
      DistanceJointDef(
        bodyA: first.body,
        bodyB: second.body,
        length: 10,
        enableSpring: true,
        hertz: 3,
        dampingRatio: 0.2,
      ),
    );
    add(JointRenderer(joint: joint));
  }
}
