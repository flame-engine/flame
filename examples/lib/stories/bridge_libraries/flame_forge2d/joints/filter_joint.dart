import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/joint_renderer.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class FilterJointExample extends Forge2DExampleGame {
  static const description = '''
    This example shows how to use a `FilterJoint`, which doesn't constrain the
    bodies at all: its only purpose is to stop two specific bodies from
    colliding with each other.

    The two balls on the left are connected by a `FilterJoint` and fall
    through each other, while the pair on the right collides as usual.
  ''';

  FilterJointExample()
    : super(gravity: Vector2(0, 10.0), world: FilterJointWorld());
}

class FilterJointWorld extends Forge2DWorld with HasGameReference<Forge2DGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    addAll(createBoundaries(game));

    // The filtered pair, which passes through itself.
    final filteredTop = Ball(Vector2(-14, -12), color: ExampleColors.emerald);
    final filteredBottom = Ball(Vector2(-14, 4), color: ExampleColors.emerald);
    await addAll([filteredTop, filteredBottom]);

    final joint = physicsWorld.createFilterJoint(
      FilterJointDef(bodyA: filteredTop.body, bodyB: filteredBottom.body),
    );
    add(JointRenderer(joint: joint, color: ExampleColors.emerald));

    // The unfiltered pair, which collides normally.
    add(Ball(Vector2(14, -12), color: ExampleColors.rose));
    add(Ball(Vector2(14, 4), color: ExampleColors.rose));
  }
}
