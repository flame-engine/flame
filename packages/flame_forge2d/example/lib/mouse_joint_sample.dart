import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/forge2d_game.dart';

import 'balls.dart';
import 'boundaries.dart';
import 'circle_stress_sample.dart';

class MouseJointSample extends Forge2DGame with MultiTouchDragDetector {
  late Ball ball;
  late Body groundBody;
  MouseJoint? mouseJoint;

  MouseJointSample() : super(gravity: Vector2(0, -10.0));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);

    final center = screenToWorld(camera.viewport.effectiveSize / 2);
    groundBody = world.createBody(BodyDef());
    ball = Ball(center, radius: 5);
    add(ball);
    add(CornerRamp(center));
    add(CornerRamp(center, isMirrored: true));
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo details) {
    final mouseJointDef = MouseJointDef()
      ..maxForce = 3000 * ball.body.mass * 10
      ..dampingRatio = 0.1
      ..frequencyHz = 5
      ..target.setFrom(ball.body.position)
      ..collideConnected = false
      ..bodyA = groundBody
      ..bodyB = ball.body;

    mouseJoint ??= world.createJoint(mouseJointDef) as MouseJoint;

    mouseJoint?.setTarget(details.eventPosition.game);
    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo details) {
    if (mouseJoint == null) {
      return true;
    }
    world.destroyJoint(mouseJoint!);
    mouseJoint = null;
    return false;
  }
}
