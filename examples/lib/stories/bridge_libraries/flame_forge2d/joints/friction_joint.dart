import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class FrictionJointExample extends Forge2DGame {
  static const description = '''
    This example shows how to use a `FrictionJoint`. Tap the screen to move the 
    ball around and observe it slows down due to the friction force.
  ''';

  FrictionJointExample()
      : super(gravity: Vector2.all(0), world: FrictionJointWorld());
}

class FrictionJointWorld extends Forge2DWorld
    with TapCallbacks, HasGameReference<Forge2DGame> {
  late Wall border;
  late Ball ball;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final boundaries = createBoundaries(game);
    border = boundaries.first;
    addAll(boundaries);

    ball = Ball(Vector2.zero(), radius: 3);
    add(ball);

    await Future.wait([ball.loaded, border.loaded]);

    createFrictionJoint(ball.body, border.body);
  }

  @override
  Future<void> onTapDown(TapDownEvent info) async {
    super.onTapDown(info);
    ball.body.applyLinearImpulse(Vector2.random() * 5000);
  }

  void createFrictionJoint(Body first, Body second) {
    final frictionJointDef = FrictionJointDef()
      ..initialize(first, second, first.worldCenter)
      ..collideConnected = true
      ..maxForce = 500
      ..maxTorque = 500;

    createJoint(FrictionJoint(frictionJointDef));
  }
}
