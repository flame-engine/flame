import 'dart:ui' hide Offset;

import 'package:flutter/material.dart';

import '../../components.dart';
import '../../geometry.dart';
import '../../palette.dart';

/// A [ShapeComponent] is a [Shape] wrapped in a [PositionComponent] so that it
/// can be added to a component tree and take the camera and viewport into
/// consideration when rendering.
class ShapeComponent extends PositionComponent with HasHitboxes {
  final HitboxShape shape;
  Paint paint;

  ShapeComponent(
    this.shape, {
    Paint? paint,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  })  : paint = paint ?? BasicPalette.white.paint(),
        super(
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        ) {
    shape.isCanvasPrepared = true;
    addHitbox(shape);
  }

  @override
  void render(Canvas canvas) {
    shape.render(canvas, paint);
  }
}

class CircleComponent extends ShapeComponent {
  CircleComponent({
    required double radius,
    Paint? paint,
    Vector2? position,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super(
          HitboxCircle(),
          paint: paint,
          position: position,
          size: Vector2.all(radius * 2),
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );
}

class RectangleComponent extends ShapeComponent {
  RectangleComponent({
    required Vector2 size,
    Paint? paint,
    Vector2? position,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super(
          HitboxRectangle(),
          paint: paint,
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  RectangleComponent.square({
    required double size,
    Paint? paint,
    Vector2? position,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super(
          HitboxRectangle(),
          paint: paint,
          position: position,
          size: Vector2.all(size),
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );
}

class PolygonComponent extends ShapeComponent {
  /// The [normalizedVertices] should be a list of points that range between
  /// [-1.0, 1.0] which defines the relation of the vertices in the polygon
  /// from the center of the component to the size of the component.
  PolygonComponent({
    required List<Vector2> normalizedVertices,
    Paint? paint,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super(
          HitboxPolygon(normalizedVertices),
          paint: paint,
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  /// Instead of using vertices that are in relation to the size of the
  /// component you can use this factory with absolute points which will set the
  /// position and size of the component and calculate the normalized vertices.
  factory PolygonComponent.fromPoints(
    List<Vector2> points, {
    Paint? paint,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) {
    final polygon = Polygon(points);
    final anchorPosition = position ??
        Anchor.center.toOtherAnchorPosition(
          polygon.position,
          anchor ?? Anchor.topLeft,
          size ?? polygon.size,
        );
    return PolygonComponent(
      normalizedVertices: polygon.normalizedVertices,
      paint: paint,
      position: anchorPosition,
      size: size ?? polygon.size,
      scale: scale,
      angle: angle,
      anchor: anchor,
      priority: priority,
    );
  }
}
