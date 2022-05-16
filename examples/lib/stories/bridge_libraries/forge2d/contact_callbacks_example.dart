import 'dart:math' as math;

import 'package:examples/stories/bridge_libraries/forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/forge2d/utils/boundaries.dart';
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
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
  }

  @override
  void onTapDown(TapDownInfo details) {
    super.onTapDown(details);
    final position = details.eventPosition.game;
    if (math.Random().nextInt(10) < 2) {
      add(WhiteBall(position));
    } else {
      add(Ball(position));
    }
  }
}
