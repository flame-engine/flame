import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class DistanceJointExample extends Forge2DGame {
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
    super.onLoad();
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

    createJoint(DistanceJoint(distanceJointDef));
  }
}
