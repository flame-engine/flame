import 'package:examples/stories/bridge_libraries/forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/forge2d/utils/boundaries.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class FrictionJointExample extends Forge2DGame with TapDetector {
  static const description = '''
    This example shows how to use a `FrictionJoint`. Tap the screen to move the 
    ball around and observe it slows down due to the friction force.
  ''';
  FrictionJointExample() : super(gravity: Vector2.all(0));

  late Wall border;
  late Ball ball;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final boundaries = createBoundaries(this);
    border = boundaries.first;
    addAll(boundaries);

    ball = Ball(size / 2, radius: 3);
    add(ball);

    await Future.wait([ball.loaded, border.loaded]);

    createJoint(ball.body, border.body);
  }

  @override
  Future<void> onTapDown(TapDownInfo info) async {
    super.onTapDown(info);
    ball.body.applyLinearImpulse(Vector2.random() * 5000);
  }

  void createJoint(Body first, Body second) {
    final frictionJointDef = FrictionJointDef()
      ..initialize(first, second, first.worldCenter)
      ..collideConnected = true
      ..maxForce = 500
      ..maxTorque = 500;

    world.createJoint(FrictionJoint(frictionJointDef));
  }
}
