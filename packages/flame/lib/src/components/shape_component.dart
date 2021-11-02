import 'dart:ui' hide Offset;

import 'package:flutter/material.dart';

import '../../components.dart';
import '../../geometry.dart';
import '../../palette.dart';
import '../anchor.dart';
import '../extensions/vector2.dart';

class ShapeComponent extends PositionComponent {
  Shape? shape;
  Paint paint = BasicPalette.white.paint();

  ShapeComponent({
    this.shape,
    Paint? paint,
    Anchor anchor = Anchor.topLeft,
    int? priority,
  }) : super(
          position: shape?.position,
          size: shape?.size,
          angle: shape?.angle ?? 0,
          anchor: anchor,
          priority: priority,
        ) {
    this.paint = paint ?? this.paint;
    shape?.isCanvasPrepared = true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    shape?.render(canvas, paint);
  }

  @override
  bool containsPoint(Vector2 point) => shape?.containsPoint(point) ?? false;

  void updateShape(Shape shape) {
    this.shape = shape..isCanvasPrepared = true;
    position = shape.position;
    size = shape.size;
    angle = shape.angle;
  }
}

class CircleComponent extends ShapeComponent {
  CircleComponent(
    double radius, {
    Vector2? position,
    Paint? paint,
    int? priority,
  }) {
    final circle = Circle(radius: radius, position: position);
    this.paint = paint ?? this.paint;
    updateShape(circle);
    changePriorityWithoutResorting(priority ?? 0);
  }
}

class RectangleComponent extends ShapeComponent {
  RectangleComponent(
    Vector2 size, {
    Vector2? position,
    Paint? paint,
    int? priority,
  }) {
    final rectangle = Rectangle(size: size, position: position);
    this.paint = paint ?? this.paint;
    updateShape(rectangle);
    changePriorityWithoutResorting(priority ?? 0);
  }

  factory RectangleComponent.square(
    double edgeLength, {
    Vector2? position,
    Paint? paint,
    int? priority,
  }) {
    return RectangleComponent(
      Vector2.all(edgeLength),
      position: position,
      paint: paint,
      priority: priority,
    );
  }
}

class PolygonComponent extends ShapeComponent {
  PolygonComponent(
    List<Vector2> points, {
    Paint? paint,
    int? priority,
  }) {
    final polygon = Polygon(points);
    this.paint = paint ?? this.paint;
    updateShape(polygon);
    changePriorityWithoutResorting(priority ?? 0);
  }

  PolygonComponent.fromDefinition(
    List<Vector2> normalizedVertices, {
    Vector2? size,
    Vector2? position,
    Paint? paint,
    int? priority,
  }) {
    final polygon = Polygon.fromDefinition(
      normalizedVertices,
      position: position,
      size: size,
    );
    this.paint = paint ?? this.paint;
    updateShape(polygon);
    changePriorityWithoutResorting(priority ?? 0);
  }
}
