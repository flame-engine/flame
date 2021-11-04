import 'dart:ui' hide Offset;

import 'package:flutter/material.dart';

import '../../components.dart';
import '../../geometry.dart';
import '../../palette.dart';
import '../anchor.dart';
import '../extensions/vector2.dart';

/// A [ShapeComponent] is a [Shape] wrapped in a [PositionComponent] so that it
/// can be added to a component tree and take the camera and viewport into
/// consideration when rendering.
class ShapeComponent extends PositionComponent {
  final Shape shape;
  Paint paint;

  /// Currently the [anchor] can only be center for [ShapeComponent], since
  /// shape doesn't take any anchor into consideration.
  @override
  final Anchor anchor = Anchor.center;

  @override
  set angle(double a) {
    super.angle = a;
    shape.angle = a;
  }

  ShapeComponent(
    this.shape, {
    Paint? paint,
    Vector2? scale,
    int? priority,
  })  : paint = paint ?? BasicPalette.white.paint(),
        super(
          position: shape.position,
          size: shape.size,
          scale: scale,
          angle: shape.angle,
          anchor: Anchor.center,
          priority: priority,
        ) {
    shape.isCanvasPrepared = true;
    position.addListener(() => shape.position.setFrom(position));
    size.addListener(() => shape.size.setFrom(position));
  }

  @override
  void render(Canvas canvas) {
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
    double size, {
    Vector2? position,
    Paint? paint,
    int? priority,
  }) : super(
          Rectangle(size: Vector2.all(size), position: position),
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
