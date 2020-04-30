import 'dart:ui';

import 'package:box2d_flame/box2d.dart';
import 'package:flame/box2d/box2d_component.dart';
import 'package:flame/box2d/viewport.dart';
import 'package:flame/palette.dart';

List<Wall> createBoundaries(Box2DComponent box) {
  final Viewport viewport = box.viewport;
  final Vector2 screenSize =
      Vector2(viewport.width, viewport.height) * viewport.scale;
  final Vector2 topLeft = viewport.getScreenToWorld(Vector2.zero());
  final Vector2 bottomRight = viewport.getScreenToWorld(screenSize);
  final Vector2 topRight = Vector2(bottomRight.x, topLeft.y);
  final Vector2 bottomLeft = Vector2(topLeft.x, bottomRight.y);

  return [
    Wall(topLeft, topRight, box),
    Wall(topRight, bottomRight, box),
    Wall(bottomRight, bottomLeft, box),
    Wall(bottomLeft, topLeft, box),
  ];
}

class Wall extends BodyComponent {
  Paint paint = BasicPalette.white.paint;
  final Vector2 start;
  final Vector2 end;

  Wall(this.start, this.end, Box2DComponent box) : super(box) {
    _createBody(start, end);
  }

  @override
  void renderPolygon(Canvas canvas, List<Offset> coordinates) {
    Offset start = coordinates[0];
    Offset end = coordinates[1];
    canvas.drawLine(start, end, paint);
  }

  void _createBody(Vector2 start, Vector2 end) {
    final PolygonShape shape = PolygonShape();
    shape.setAsEdge(start, end);

    final fixtureDef = FixtureDef();
    fixtureDef.setUserData(this); // To be able to determine object in collision
    fixtureDef.shape = shape;
    fixtureDef.restitution = 0.0;
    fixtureDef.friction = 0.1;

    final bodyDef = BodyDef();
    bodyDef.position = Vector2.zero();
    bodyDef.type = BodyType.STATIC;

    body = world.createBody(bodyDef)..createFixtureFromFixtureDef(fixtureDef);
  }
}
