import 'dart:math' as math;

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class ContactCallbacksExample extends Forge2DGame with TapDetector {
  static const description = '''
    This example shows how `BodyComponent`s can react to collisions with other
    bodies.
    Tap the screen to add balls, the white balls will give an impulse to the
    balls that it collides with.
  ''';

  ContactCallbacksExample() : super(gravity: Vector2(0, 10.0));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final boundaries = createBoundaries(this);
    world.addAll(boundaries);
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    final position = screenToWorld(info.eventPosition.widget);
    if (math.Random().nextInt(10) < 2) {
      world.add(WhiteBall(position));
    } else {
      world.add(Ball(position));
    }
  }
}
