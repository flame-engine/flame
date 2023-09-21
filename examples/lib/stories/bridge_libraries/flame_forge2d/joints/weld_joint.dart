import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boxes.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class WeldJointExample extends Forge2DGame {
  static const description = '''
    This example shows how to use a `WeldJoint`. Tap the screen to add a 
    ball to test the bridge built using a `WeldJoint`
  ''';

  WeldJointExample() : super(world: WeldJointWorld());
}

class WeldJointWorld extends Forge2DWorld
    with TapCallbacks, HasGameReference<Forge2DGame> {
  final pillarHeight = 20.0;
  final pillarWidth = 5.0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final leftPillar = Box(
      startPosition: game.screenToWorld(Vector2(50, game.size.y))
        ..y -= pillarHeight / 2,
      width: pillarWidth,
      height: pillarHeight,
      bodyType: BodyType.static,
      color: Colors.white,
    );
    final rightPillar = Box(
      startPosition: game.screenToWorld(Vector2(game.size.x - 50, game.size.y))
        ..y -= pillarHeight / 2,
      width: pillarWidth,
      height: pillarHeight,
      bodyType: BodyType.static,
      color: Colors.white,
    );

    await addAll([leftPillar, rightPillar]);

    createBridge(leftPillar, rightPillar);
  }

  Future<void> createBridge(
    Box leftPillar,
    Box rightPillar,
  ) async {
    const sectionsCount = 10;
    // Vector2.zero is used here since 0,0 is in the middle and 0,0 in the
    // screen space then gives us the coordinates of the upper left corner in
    // world space.
    final halfSize = game.screenToWorld(Vector2.zero())..absolute();
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
      await add(section);

      if (prevSection != null) {
        createWeldJoint(
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

  void createWeldJoint(Body first, Body second, Vector2 anchor) {
    final weldJointDef = WeldJointDef()..initialize(first, second, anchor);

    createJoint(WeldJoint(weldJointDef));
  }

  @override
  Future<void> onTapDown(TapDownEvent info) async {
    super.onTapDown(info);
    final ball = Ball(info.localPosition, radius: 5);
    add(ball);
  }
}
