import 'dart:math' as math;

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class ContactCallbacksExample extends Forge2DGame {
  static const description = '''
    This example shows how `BodyComponent`s can react to collisions with other
    bodies.
    Tap the screen to add balls, the white balls will give an impulse to the
    balls that it collides with.
  ''';

  ContactCallbacksExample()
      : super(gravity: Vector2(0, 10.0), world: ContactCallbackWorld());
}

class ContactCallbackWorld extends Forge2DWorld
    with TapCallbacks, HasGameReference<Forge2DGame> {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    final boundaries = createBoundaries(game);
    addAll(boundaries);
  }

  @override
  void onTapDown(TapDownEvent info) {
    super.onTapDown(info);
    final position = info.localPosition;
    if (math.Random().nextInt(10) < 2) {
      add(WhiteBall(position));
    } else {
      add(Ball(position));
    }
  }
}
