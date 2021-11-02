import 'dart:ui' hide Offset;

import 'package:flutter/material.dart';

import '../../components.dart';
import '../../geometry.dart';
import '../../palette.dart';
import '../anchor.dart';
import '../extensions/vector2.dart';

class ShapeComponent extends PositionComponent {
  final Shape shape;
  Paint paint;

  ShapeComponent(
    this.shape, {
    Paint? paint,
    Anchor anchor = Anchor.topLeft,
    int? priority,
  })  : paint = paint ?? BasicPalette.white.paint(),
        super(
          position: shape.position,
          size: shape.size,
          angle: shape.angle,
          anchor: anchor,
          priority: priority,
        ) {
    shape.isCanvasPrepared = true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    shape.render(canvas, paint);
  }

  @override
  bool containsPoint(Vector2 point) => shape.containsPoint(point);
}

class CircleComponent extends ShapeComponent {
  CircleComponent(
    double radius, {
    Vector2? position,
    Paint? paint,
    int? priority,
  }) : super(
          Circle(radius: radius, position: position),
          paint: paint,
          priority: priority,
        );
}

class RectangleComponent extends ShapeComponent {
  RectangleComponent(
    Vector2 size, {
    Vector2? position,
    Paint? paint,
    int? priority,
  }) : super(
          Rectangle(size: size, position: position),
          paint: paint,
          priority: priority,
        );

  RectangleComponent.square(
    double edgeLength, {
    Vector2? position,
    Paint? paint,
    int? priority,
  }) : super(
          Rectangle(size: Vector2.all(edgeLength), position: position),
          paint: paint,
          priority: priority,
        );
}

class PolygonComponent extends ShapeComponent {
  PolygonComponent(
    List<Vector2> points, {
    Paint? paint,
    int? priority,
  }) : super(Polygon(points), paint: paint, priority: priority);

  PolygonComponent.fromDefinition(
    List<Vector2> normalizedVertices, {
    Vector2? size,
    Vector2? position,
    Paint? paint,
    int? priority,
  }) : super(
          Polygon.fromDefinition(
            normalizedVertices,
            position: position,
            size: size,
          ),
          paint: paint,
          priority: priority,
        );
}
