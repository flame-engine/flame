import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

List<Wall> createBoundaries(Forge2DGame game, {double? strokeWidth}) {
  final visibleRect = game.camera.visibleWorldRect;
  final topLeft = visibleRect.topLeft.toVector2();
  final topRight = visibleRect.topRight.toVector2();
  final bottomRight = visibleRect.bottomRight.toVector2();
  final bottomLeft = visibleRect.bottomLeft.toVector2();

  return [
    Wall(topLeft, topRight, strokeWidth: strokeWidth),
    Wall(topRight, bottomRight, strokeWidth: strokeWidth),
    Wall(bottomLeft, bottomRight, strokeWidth: strokeWidth),
    Wall(topLeft, bottomLeft, strokeWidth: strokeWidth),
  ];
}

class Wall extends BodyComponent with GlowingBody {
  final Vector2 start;
  final Vector2 end;
  final double strokeWidth;

  Wall(this.start, this.end, {double? strokeWidth})
    : strokeWidth = strokeWidth ?? 0.15 {
    paint = Paint()..color = ExampleColors.slate;
  }

  @override
  double get outlineWidth => strokeWidth;

  @override
  Body createBody() {
    // The default material gives the walls enough grip for bodies to come
    // to rest against them instead of sliding along.
    final shapeDef = ShapeDef(enableContactEvents: true);
    final bodyDef = BodyDef(
      userData: this, // To be able to determine object in collision
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)
      ..createShape(Segment(point1: start, point2: end), shapeDef);
  }
}
