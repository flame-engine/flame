import 'dart:ui';

import 'polygon.dart';
import 'shape.dart';
import '../../extensions.dart';
import '../../geometry.dart';

abstract class Intersections<T1 extends Shape, T2 extends Shape> {
  Set<Vector2> intersect(T1 shapeA, T2 shapeB);

  bool supportsShapes(Shape shapeA, Shape shapeB) {
    return shapeA is T1 && shapeB is T2;
  }
}

class PolygonPolygonIntersections extends Intersections<Polygon, Polygon> {
  /// Returns the intersection points of [polygonA] and [polygonB]
  /// The two polygons are required to be convex
  /// If they share a segment of a line, both end points and the center point of
  /// that line segment will be counted as collision points
  // TODO: Do we really have to return the center point too?
  @override
  Set<Vector2> intersect(Polygon polygonA, Polygon polygonB,
      {Rect overlappingRect}) {
    final intersectionPoints = <Vector2>{};
    final intersectionsA = _possibleIntersectionVertices(
      polygonA.hitbox,
      overlappingRect,
    );
    final intersectionsB = _possibleIntersectionVertices(
      polygonB.hitbox,
      overlappingRect,
    );
    for (LineSegment lineA in intersectionsA) {
      for (LineSegment lineB in intersectionsB) {
        intersectionPoints.addAll(lineA.intersections(lineB));
      }
    }
    return intersectionPoints;
  }

  /// Return all [vertices] as [LineSegment]s that intersect [rect], if [rect]
  /// is null return all [vertices] as [LineSegment]s.
  List<LineSegment> _possibleIntersectionVertices(
    List<Vector2> vertices,
    Rect rect,
  ) {
    final List<LineSegment> rectIntersections = [];
    for (int i = 0; i < vertices.length; i++) {
      final from = vertices[i];
      final to = vertices[(i + 1) % vertices.length];
      if (rect?.containsVertex(from, to) ?? true) {
        rectIntersections.add(LineSegment(from, to));
      }
    }
    return rectIntersections;
  }
}

final List<Type> _shapeOrder = [Polygon];
final List<Intersections> _intersectionSystems = [
  PolygonPolygonIntersections()
];

Set<Vector2> intersections(Shape shapeA, Shape shapeB) {
  final isShapeAFirst = _shapeOrder.indexOf(shapeA.runtimeType) <=
      _shapeOrder.indexOf(shapeB.runtimeType);
  shapeA = isShapeAFirst ? shapeA : shapeB;
  shapeB = isShapeAFirst ? shapeB : shapeA;
  final intersectionSystem = _intersectionSystems.firstWhere(
    (system) => system.supportsShapes(shapeA, shapeB),
    orElse: () {
      print(shapeA);
      print(shapeB);
      throw 'Non-supported shape detected';
    },
  );
  return intersectionSystem.intersect(shapeA, shapeB);
}
