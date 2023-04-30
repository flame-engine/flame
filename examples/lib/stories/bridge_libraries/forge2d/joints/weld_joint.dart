import 'package:examples/stories/bridge_libraries/forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/forge2d/utils/boxes.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class WeldJointExample extends Forge2DGame with TapDetector {
  static const description = '''
    This example shows how to use a `WeldJoint`. Tap the screen to add a 
    ball to test the bridge built using a `WeldJoint`
  ''';

  @override
  Future<void> onLoad() async {
    super.onLoad();

    const pillarHeight = 20.0;
    final leftPillar = Box(
      startPosition: Vector2(10, size.y - pillarHeight / 2),
      width: 5,
      height: pillarHeight,
      bodyType: BodyType.static,
      color: Colors.white,
    );
    final rightPillar = Box(
      startPosition: Vector2(size.x - 10, size.y - pillarHeight / 2),
      width: 5,
      height: pillarHeight,
      bodyType: BodyType.static,
      color: Colors.white,
    );

    addAll([leftPillar, rightPillar]);

    createBridge(size.y - pillarHeight);
  }

  Future<void> createBridge(double positionY) async {
    const sectionsCount = 10;
    final sectionWidth = (size.x / sectionsCount).ceilToDouble();
    Body? prevSection;

    for (var i = 0; i < sectionsCount; i++) {
      final section = Box(
        startPosition: Vector2(sectionWidth * i, positionY),
        width: sectionWidth,
        height: 1,
      );
      await add(section);

      if (prevSection != null) {
        createJoint(
          prevSection,
          section.body,
          Vector2(sectionWidth * i + sectionWidth, positionY),
        );
      }

      prevSection = section.body;
    }
  }

  void createJoint(Body first, Body second, Vector2 anchor) {
    final weldJointDef = WeldJointDef()..initialize(first, second, anchor);

    world.createJoint(WeldJoint(weldJointDef));
  }

  @override
  Future<void> onTapDown(TapDownInfo info) async {
    super.onTapDown(info);
    final ball = Ball(info.eventPosition.game, radius: 5);
    add(ball);
  }
}
