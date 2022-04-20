import 'dart:math' as math;

import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'balls.dart';
import 'boundaries.dart';

class ContactCallbacksSample extends Forge2DGame with TapDetector {
  static const info = '''
This example shows how `BodyComponent`s can react to collisions with other
bodies.
Tap the screen to add balls, the white balls will give an impulse to the balls
that it collides with.
''';
  ContactCallbacksSample() : super(gravity: Vector2(0, 10.0));

  @override
  Future<void> onLoad() async {
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
    addContactCallback(BallContactCallback());
    addContactCallback(BallWallContactCallback());
    addContactCallback(WhiteBallContactCallback());
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
