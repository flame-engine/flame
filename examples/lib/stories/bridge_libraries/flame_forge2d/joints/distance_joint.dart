import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class DistanceJointExample extends Forge2DGame with TapDetector {
  static const description = '''
    This example shows how to use a `DistanceJoint`. Tap the screen to add a 
    pair of balls joined with a `DistanceJoint`.
  ''';

  @override
  Future<void> onLoad() async {
    super.onLoad();
    world.addAll(createBoundaries(this));
  }

  @override
  Future<void> onTapDown(TapDownInfo info) async {
    super.onTapDown(info);
    final tap = screenToWorld(info.eventPosition.widget);

    final first = Ball(tap);
    final second = Ball(Vector2(tap.x + 3, tap.y + 3));
    world.addAll([first, second]);

    await Future.wait([first.loaded, second.loaded]);

    createJoint(first, second);
  }

  void createJoint(Ball first, Ball second) {
    final distanceJointDef = DistanceJointDef()
      ..initialize(
        first.body,
        second.body,
        first.body.worldCenter,
        second.center,
      )
      ..length = 10
      ..frequencyHz = 3
      ..dampingRatio = 0.2;

    world.createJoint(DistanceJoint(distanceJointDef));
  }
}
