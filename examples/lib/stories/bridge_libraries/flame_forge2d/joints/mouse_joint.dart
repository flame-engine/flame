import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/joint_renderer.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class MouseJointExample extends Forge2DExampleGame {
  static const description = '''
    In this example we use a `MouseJoint` to make the ball follow the mouse
    when you drag it around. The line shows the joint pulling the ball
    towards the pointer.
  ''';

  MouseJointExample()
    : super(gravity: Vector2(0, 10.0), world: MouseJointWorld());
}

class MouseJointWorld extends Forge2DWorld
    with DragCallbacks, HasGameReference<Forge2DGame> {
  late Ball ball;
  late Body groundBody;
  MouseJoint? mouseJoint;
  MouseJointRenderer? _jointRenderer;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final boundaries = createBoundaries(game);
    addAll(boundaries);

    groundBody = createBody(BodyDef());
    ball = Ball(Vector2.zero(), radius: 5, color: ExampleColors.amber);
    add(ball);
  }

  @override
  void onDragStart(DragStartEvent info) {
    super.onDragStart(info);
    if (mouseJoint != null) {
      return;
    }
    final joint = physicsWorld.createMouseJoint(
      MouseJointDef(
        bodyA: groundBody,
        bodyB: ball.body,
        target: ball.body.position,
        maxForce: 3000 * ball.body.mass * 10,
        dampingRatio: 0.1,
        hertz: 5,
      ),
    );
    mouseJoint = joint;
    _jointRenderer = MouseJointRenderer(joint: joint);
    add(_jointRenderer!);
  }

  @override
  void onDragUpdate(DragUpdateEvent info) {
    mouseJoint?.target = info.localEndPosition;
  }

  @override
  void onDragEnd(DragEndEvent info) {
    super.onDragEnd(info);
    mouseJoint?.destroy();
    mouseJoint = null;
    _jointRenderer?.removeFromParent();
    _jointRenderer = null;
  }
}
