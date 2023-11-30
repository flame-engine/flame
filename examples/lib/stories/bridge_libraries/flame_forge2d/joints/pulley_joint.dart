import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boxes.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class PulleyJointExample extends Forge2DGame {
  static const description = '''
    This example shows how to use a `PulleyJoint`. Drag one of the boxes and see 
    how the other one gets moved by the pulley
  ''';

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final distanceFromCenter = camera.visibleWorldRect.width / 5;

    final firstPulley = Ball(
      Vector2(-distanceFromCenter, -10),
      bodyType: BodyType.static,
    );
    final secondPulley = Ball(
      Vector2(distanceFromCenter, -10),
      bodyType: BodyType.static,
    );

    final firstBox = DraggableBox(
      startPosition: Vector2(-distanceFromCenter, 20),
      width: 5,
      height: 10,
    );
    final secondBox = DraggableBox(
      startPosition: Vector2(distanceFromCenter, 20),
      width: 7,
      height: 10,
    );
    world.addAll([firstBox, secondBox, firstPulley, secondPulley]);

    await Future.wait([
      firstBox.loaded,
      secondBox.loaded,
      firstPulley.loaded,
      secondPulley.loaded,
    ]);

    final joint = createJoint(firstBox, secondBox, firstPulley, secondPulley);
    world.add(PulleyRenderer(joint: joint));
  }

  PulleyJoint createJoint(
    Box firstBox,
    Box secondBox,
    Ball firstPulley,
    Ball secondPulley,
  ) {
    final pulleyJointDef = PulleyJointDef()
      ..initialize(
        firstBox.body,
        secondBox.body,
        firstPulley.center,
        secondPulley.center,
        firstBox.body.worldPoint(Vector2(0, -firstBox.height / 2)),
        secondBox.body.worldPoint(Vector2(0, -secondBox.height / 2)),
        1,
      );
    final joint = PulleyJoint(pulleyJointDef);
    world.createJoint(joint);
    return joint;
  }
}

class PulleyRenderer extends Component {
  PulleyRenderer({required this.joint});

  final PulleyJoint joint;

  @override
  void render(Canvas canvas) {
    canvas.drawLine(
      joint.anchorA.toOffset(),
      joint.getGroundAnchorA().toOffset(),
      debugPaint,
    );

    canvas.drawLine(
      joint.anchorB.toOffset(),
      joint.getGroundAnchorB().toOffset(),
      debugPaint,
    );

    canvas.drawLine(
      joint.getGroundAnchorA().toOffset(),
      joint.getGroundAnchorB().toOffset(),
      debugPaint,
    );
  }
}
