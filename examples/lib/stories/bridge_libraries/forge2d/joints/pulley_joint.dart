import 'dart:ui';

import 'package:examples/stories/bridge_libraries/forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/forge2d/utils/boxes.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class PulleyJointExample extends Forge2DGame with TapDetector, HasDraggables {
  static const description = '''
    This example shows how to use a `PulleyJoint`. Drag one of the boxes and see 
    how the other one gets moved by the pulley
  ''';

  late final Ball firstPulley;
  late final Ball secondPulley;
  late final PulleyJoint joint;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    firstPulley = Ball(Vector2(size.x * 0.33, 10), bodyType: BodyType.static);
    secondPulley = Ball(Vector2(size.x * 0.66, 10), bodyType: BodyType.static);

    final firstBox = DraggableBox(
      startPosition: Vector2(size.x * 0.33, size.y / 2),
      width: 5,
      height: 10,
    );
    final secondBox = DraggableBox(
      startPosition: Vector2(size.x * 0.66, size.y / 2),
      width: 7,
      height: 10,
    );
    addAll([firstBox, secondBox, firstPulley, secondPulley]);

    await Future.wait([
      firstBox.loaded,
      secondBox.loaded,
      firstPulley.loaded,
      secondPulley.loaded
    ]);

    createJoint(firstBox, secondBox);
  }

  void createJoint(Box first, Box second) {
    final pulleyJointDef = PulleyJointDef()
      ..initialize(
        first.body,
        second.body,
        firstPulley.center,
        secondPulley.center,
        first.body.worldPoint(Vector2(0, -first.height / 2)),
        second.body.worldPoint(Vector2(0, -second.height / 2)),
        1,
      );
    joint = PulleyJoint(pulleyJointDef);
    world.createJoint(joint);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final firstBodyAnchor = worldToScreen(joint.anchorA).toOffset();
    final firstPulleyAnchor =
        worldToScreen(joint.getGroundAnchorA()).toOffset();
    canvas.drawLine(firstBodyAnchor, firstPulleyAnchor, debugPaint);

    final secondBodyAnchor = worldToScreen(joint.anchorB).toOffset();
    final secondPulleyAnchor =
        worldToScreen(joint.getGroundAnchorB()).toOffset();
    canvas.drawLine(secondBodyAnchor, secondPulleyAnchor, debugPaint);

    canvas.drawLine(firstPulleyAnchor, secondPulleyAnchor, debugPaint);
  }
}
