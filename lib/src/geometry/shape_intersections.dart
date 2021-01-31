import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'circle.dart';
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
    final intersectionsA = polygonA.possibleIntersectionVertices(
      overlappingRect,
    );
    final intersectionsB = polygonB.possibleIntersectionVertices(
      overlappingRect,
    );
    for (LineSegment lineA in intersectionsA) {
      for (LineSegment lineB in intersectionsB) {
        intersectionPoints.addAll(lineA.intersections(lineB));
      }
    }
    return intersectionPoints;
  }
}

class CirclePolygonIntersections extends Intersections<Circle, Polygon> {
  @override
  Set<Vector2> intersect(Circle circle, Polygon polygon,
      {Rect overlappingRect}) {
    final intersectionPoints = <Vector2>{};
    final possibleVertices = polygon.possibleIntersectionVertices(
      overlappingRect,
    );
    for (LineSegment line in possibleVertices) {
      intersectionPoints.addAll(circle.lineSegmentIntersections(line));
    }
    return intersectionPoints;
  }
}

class CircleCircleIntersections extends Intersections<Circle, Circle> {
  @override
  Set<Vector2> intersect(Circle shapeA, Circle shapeB) {
    final distance =
        shapeA.absolutePosition.distanceTo(shapeB.absolutePosition);
    final radiusA = shapeA.radius;
    final radiusB = shapeB.radius;
    if (distance > radiusA + radiusB) {
      // Since the circles are too far away from each other to intersect we
      // return the empty set.
      return {};
    } else if (distance < (radiusA - radiusB).abs()) {
      // Since one circle is contained within the other there can't be any
      // intersections.
      return {};
    } else if (distance == 0 && radiusA == radiusB) {
      // The circles are identical and on top of each other, so there are an
      // infinite number of solutions. Since it is problematic to return a
      // set of infinite size, we'll return 4 distinct points here.
      return {
        shapeA.absolutePosition + Vector2(radiusA, 0),
        shapeA.absolutePosition + Vector2(0, -radiusA),
        shapeA.absolutePosition + Vector2(-radiusA, 0),
        shapeA.absolutePosition + Vector2(0, radiusA),
      };
    } else {
      final cathetusA = (pow(radiusA, 2) - pow(radiusB, 2) + pow(distance, 2)) /
          (2 * distance);
      // Length of h
      final cathetusB = sqrt((pow(radiusA, 2) - pow(cathetusA, 2)).abs());
      // P2 = P0 + a ( P1 - P0 ) / d
      final centerPoint = shapeA.absolutePosition +
          (shapeB.absolutePosition - shapeA.absolutePosition) *
              cathetusA /
              distance;
      print(radiusA);
      print(centerPoint);
      print(cathetusA);
      print(cathetusB);
      print(distance);
      // x3 = x2 +- h ( y1 - y0 ) / d
      // y3 = y2 -+ h ( x1 - x0 ) / d
      final deltaX = cathetusB *
          (shapeB.absolutePosition.y - shapeA.absolutePosition.y).abs() /
          distance;
      final deltaY = cathetusB *
          (shapeB.absolutePosition.x - shapeA.absolutePosition.x).abs() /
          distance;
      return {
        Vector2(centerPoint.x + deltaX, centerPoint.y - deltaY),
        Vector2(centerPoint.x - deltaX, centerPoint.y + deltaY),
      };
    }
  }
}

final List<Type> _shapeOrder = [Circle, Polygon];
final List<Intersections> _intersectionSystems = [
  CircleCircleIntersections(),
  CirclePolygonIntersections(),
  PolygonPolygonIntersections(),
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
