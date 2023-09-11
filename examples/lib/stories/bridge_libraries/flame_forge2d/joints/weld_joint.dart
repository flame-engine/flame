import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boxes.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class WeldJointExample extends Forge2DGame with TapDetector {
  static const description = '''
    This example shows how to use a `WeldJoint`. Tap the screen to add a 
    ball to test the bridge built using a `WeldJoint`
  ''';

  final pillarHeight = 20.0;
  final pillarWidth = 5.0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final leftPillar = Box(
      startPosition: screenToWorld(Vector2(50, size.y))..y -= pillarHeight / 2,
      width: pillarWidth,
      height: pillarHeight,
      bodyType: BodyType.static,
      color: Colors.white,
    );
    final rightPillar = Box(
      startPosition: screenToWorld(Vector2(size.x - 50, size.y))
        ..y -= pillarHeight / 2,
      width: pillarWidth,
      height: pillarHeight,
      bodyType: BodyType.static,
      color: Colors.white,
    );

    await world.addAll([leftPillar, rightPillar]);

    createBridge(leftPillar, rightPillar);
  }

  Future<void> createBridge(
    Box leftPillar,
    Box rightPillar,
  ) async {
    const sectionsCount = 10;
    // Vector2.zero is used here since 0,0 is in the middle and 0,0 in the
    // screen space then gives us the
    final halfSize = screenToWorld(Vector2.zero())..absolute();
    final sectionWidth = ((leftPillar.center.x.abs() +
                rightPillar.center.x.abs() +
                pillarWidth) /
            sectionsCount)
        .ceilToDouble();
    Body? prevSection;

    for (var i = 0; i < sectionsCount; i++) {
      final section = Box(
        startPosition: Vector2(
          sectionWidth * i - halfSize.x + sectionWidth / 2,
          halfSize.y - pillarHeight,
        ),
        width: sectionWidth,
        height: 1,
      );
      await world.add(section);

      if (prevSection != null) {
        createJoint(
          prevSection,
          section.body,
          Vector2(
            sectionWidth * i - halfSize.x + sectionWidth,
            halfSize.y - pillarHeight,
          ),
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
    final ball = Ball(screenToWorld(info.eventPosition.global), radius: 5);
    world.add(ball);
  }
}
