import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../extensions.dart';
import '../../geometry.dart';
import 'circle.dart';
import 'polygon.dart';
import 'shape.dart';

abstract class Intersections<T1 extends Shape, T2 extends Shape> {
  Set<Vector2> intersect(T1 shapeA, T2 shapeB);

  bool supportsShapes(Shape shapeA, Shape shapeB) {
    return shapeA is T1 && shapeB is T2 || shapeA is T2 && shapeB is T1;
  }

  Set<Vector2> unorderedIntersect(Shape shapeA, Shape shapeB) {
    if (shapeA is T1 && shapeB is T2) {
      return intersect(shapeA, shapeB);
    } else if (shapeA is T2 && shapeB is T1) {
      return intersect(shapeB, shapeA);
    } else {
      throw 'Unsupported shapes';
    }
  }
}

class PolygonPolygonIntersections extends Intersections<Polygon, Polygon> {
  /// Returns the intersection points of [polygonA] and [polygonB]
  /// The two polygons are required to be convex
  /// If they share a segment of a line, both end points and the center point of
  /// that line segment will be counted as collision points
  @override
  Set<Vector2> intersect(
    Polygon polygonA,
    Polygon polygonB, {
    Rect? overlappingRect,
  }) {
    final intersectionPoints = <Vector2>{};
    final intersectionsA = polygonA.possibleIntersectionVertices(
      overlappingRect,
    );
    final intersectionsB = polygonB.possibleIntersectionVertices(
      overlappingRect,
    );
    for (final lineA in intersectionsA) {
      for (final lineB in intersectionsB) {
        intersectionPoints.addAll(lineA.intersections(lineB));
      }
    }
    return intersectionPoints;
  }
}

class CirclePolygonIntersections extends Intersections<Circle, Polygon> {
  @override
  Set<Vector2> intersect(
    Circle circle,
    Polygon polygon, {
    Rect? overlappingRect,
  }) {
    final intersectionPoints = <Vector2>{};
    final possibleVertices = polygon.possibleIntersectionVertices(
      overlappingRect,
    );
    for (final line in possibleVertices) {
      intersectionPoints.addAll(circle.lineSegmentIntersections(line));
    }
    return intersectionPoints;
  }
}

class CircleCircleIntersections extends Intersections<Circle, Circle> {
  @override
  Set<Vector2> intersect(Circle shapeA, Circle shapeB) {
    final distance = shapeA.absoluteCenter.distanceTo(shapeB.absoluteCenter);
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
        shapeA.absoluteCenter + Vector2(radiusA, 0),
        shapeA.absoluteCenter + Vector2(0, -radiusA),
        shapeA.absoluteCenter + Vector2(-radiusA, 0),
        shapeA.absoluteCenter + Vector2(0, radiusA),
      };
    } else {
      /// There are definitely collision points if we end up in here.
      /// To calculate these we use the fact that we can form two triangles going
      /// between the center of shapeA, the point in between the shapes which the
      /// intersecting line goes through, and then two different triangles are
      /// formed with the two intersection points as the last corners.
      /// The length to the point in between the circles is first calculated,
      /// this is [lengthA], then we calculate the length of the other cathetus
      /// [lengthB]. Then the [centerPoint] is calculated, which is the point
      /// which the intersecting line goes through in between the shapes.
      /// At this point we know the two first points of the triangles, the center
      /// of [shapeA] and the [centerPoint], the two third points of the
      /// different triangles are the intersection points that we are looking for
      /// and we get those points by calculating the [delta] from the
      /// [centerPoint] to the intersection points.
      /// The result is then [centerPoint] +- [delta].
      final lengthA = (pow(radiusA, 2) - pow(radiusB, 2) + pow(distance, 2)) /
          (2 * distance);
      final lengthB = sqrt((pow(radiusA, 2) - pow(lengthA, 2)).abs());
      final centerPoint = shapeA.absoluteCenter +
          (shapeB.absoluteCenter - shapeA.absoluteCenter) * lengthA / distance;
      final delta = Vector2(
        lengthB *
            (shapeB.absoluteCenter.y - shapeA.absoluteCenter.y).abs() /
            distance,
        -lengthB *
            (shapeB.absoluteCenter.x - shapeA.absoluteCenter.x).abs() /
            distance,
      );
      return {
        centerPoint + delta,
        centerPoint - delta,
      };
    }
  }
}

final List<Intersections> _intersectionSystems = [
  CircleCircleIntersections(),
  CirclePolygonIntersections(),
  PolygonPolygonIntersections(),
];

Set<Vector2> intersections(Shape shapeA, Shape shapeB) {
  final intersectionSystem = _intersectionSystems.firstWhere(
    (system) => system.supportsShapes(shapeA, shapeB),
    orElse: () {
      throw 'Unsupported shape detected + ${shapeA.runtimeType} ${shapeB.runtimeType}';
    },
  );
  return intersectionSystem.unorderedIntersect(shapeA, shapeB);
}
