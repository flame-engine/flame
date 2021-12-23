import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/geometry.dart' as geometry;
import 'package:test/test.dart';

void main() {
  group('LineSegment.isPointOnSegment', () {
    test('can catch simple point', () {
      final segment = LineSegment(
        Vector2.all(0),
        Vector2.all(1),
      );
      final point = Vector2.all(0.5);
      expect(
        segment.containsPoint(point),
        true,
        reason: 'Point should be on segment',
      );
    });

    test('should not catch point outside of segment, but on line', () {
      final segment = LineSegment(
        Vector2.all(0),
        Vector2.all(1),
      );
      final point = Vector2.all(3);
      expect(
        segment.containsPoint(point),
        false,
        reason: 'Point should not be on segment',
      );
    });

    test('should not catch point outside of segment', () {
      final segment = LineSegment(
        Vector2.all(0),
        Vector2.all(1),
      );
      final point = Vector2(3, 2);
      expect(
        segment.containsPoint(point),
        false,
        reason: 'Point should not be on segment',
      );
    });

    test('point on end of segment', () {
      final segment = LineSegment(
        Vector2.all(0),
        Vector2.all(1),
      );
      final point = Vector2.all(1);
      expect(
        segment.containsPoint(point),
        true,
        reason: 'Point should be on segment',
      );
    });

    test('point on beginning of segment', () {
      final segment = LineSegment(
        Vector2.all(0),
        Vector2.all(1),
      );
      final point = Vector2.all(0);
      expect(
        segment.containsPoint(point),
        true,
        reason: 'Point should be on segment',
      );
    });
  });

  group('LineSegment.intersections', () {
    test('simple intersection', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2(0, 1), Vector2(1, 0));
      final intersection = segmentA.intersections(segmentB);
      expect(
        intersection.isNotEmpty,
        true,
        reason: 'Should have intersection at (0.5, 0.5)',
      );
      expect(intersection.first == Vector2.all(0.5), true);
    });

    test('no intersection', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2(0, 1), Vector2(1, 2));
      final intersection = segmentA.intersections(segmentB);
      expect(
        intersection.isEmpty,
        true,
        reason: 'Should not have any intersection',
      );
    });

    test('same line segments', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2.all(0), Vector2.all(1));
      final intersection = segmentA.intersections(segmentB);
      expect(
        intersection.isNotEmpty,
        true,
        reason: 'Should have intersection at (0.5, 0.5)',
      );
      expect(intersection.first == Vector2.all(0.5), true);
    });

    test('overlapping line segments', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2.all(0.5), Vector2.all(1.5));
      final intersection = segmentA.intersections(segmentB);
      expect(
        intersection.isNotEmpty,
        true,
        reason: 'Should intersect at (0.75, 0.75)',
      );
      expect(intersection.first == Vector2.all(0.75), true);
    });

    test('one pixel overlap in different angles', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2.all(0), Vector2(1, -1));
      final intersection = segmentA.intersections(segmentB);
      expect(
        intersection.isNotEmpty,
        true,
        reason: 'Should have intersection at (0, 0)',
      );
      expect(intersection.first == Vector2.all(0), true);
    });

    test('one pixel parallel overlap in same angle', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2.all(1), Vector2.all(2));
      final intersection = segmentA.intersections(segmentB);
      expect(
        intersection.isNotEmpty,
        true,
        reason: 'Should have intersection at (1, 1)',
      );
      expect(intersection.first == Vector2.all(1), true);
    });
  });

  group('Line.intersections', () {
    test('simple line intersection', () {
      const line1 = Line(1, -1, 0);
      const line2 = Line(1, 1, 0);
      final intersection = line1.intersections(line2);
      expect(intersection.isNotEmpty, true, reason: 'Should have intersection');
      expect(intersection.first == Vector2.all(0), true);
    });

    test('lines with c value', () {
      const line1 = Line(1, 1, 1);
      const line2 = Line(1, -1, 1);
      final intersection = line1.intersections(line2);
      expect(intersection.isNotEmpty, true, reason: 'Should have intersection');
      expect(intersection.first == Vector2(1, 0), true);
    });

    test('does not catch parallel lines', () {
      const line1 = Line(1, 1, -3);
      const line2 = Line(1, 1, 6);
      final intersection = line1.intersections(line2);
      expect(
        intersection.isEmpty,
        true,
        reason: 'Should not have intersection',
      );
    });

    test('does not catch same line', () {
      const line1 = Line(1, 1, 1);
      const line2 = Line(1, 1, 1);
      final intersection = line1.intersections(line2);
      expect(
        intersection.isEmpty,
        true,
        reason: 'Should not have intersection',
      );
    });
  });

  group('LinearEquation.fromPoints', () {
    test('simple line from points', () {
      final line = Line.fromPoints(Vector2.zero(), Vector2.all(1));
      expect(line.a == 1.0, true, reason: 'a value is not correct');
      expect(line.b == -1.0, true, reason: 'b value is not correct');
      expect(line.c == 0.0, true, reason: 'c value is not correct');
    });

    test('line not going through origin', () {
      final line = Line.fromPoints(Vector2(-2, 0), Vector2(0, 2));
      expect(line.a == 2.0, true, reason: 'a value is not correct');
      expect(line.b == -2.0, true, reason: 'b value is not correct');
      expect(line.c == -4.0, true, reason: 'c value is not correct');
    });

    test('straight vertical line', () {
      final line = Line.fromPoints(Vector2.all(1), Vector2(1, -1));
      expect(line.a == -2.0, true, reason: 'a value is not correct');
      expect(line.b == 0.0, true, reason: 'b value is not correct');
      expect(line.c == -2.0, true, reason: 'c value is not correct');
    });

    test('straight horizontal line', () {
      final line = Line.fromPoints(Vector2.all(1), Vector2(2, 1));
      expect(line.a == 0.0, true, reason: 'a value is not correct');
      expect(line.b == -1.0, true, reason: 'b value is not correct');
      expect(line.c == -1.0, true, reason: 'c value is not correct');
    });
  });

  group('LineSegment.pointsAt', () {
    test('simple pointing', () {
      final segment = LineSegment(Vector2.zero(), Vector2.all(1));
      const line = Line(1, 1, 3);
      final isPointingAt = segment.pointsAt(line);
      expect(isPointingAt, true, reason: 'Line should be pointed at');
    });

    test('is not pointed at when crossed', () {
      final segment = LineSegment(Vector2.zero(), Vector2.all(3));
      const line = Line(1, 1, 3);
      final isPointingAt = segment.pointsAt(line);
      expect(isPointingAt, false, reason: 'Line should not be pointed at');
    });

    test('is not pointed at when parallel', () {
      final segment = LineSegment(Vector2.zero(), Vector2(1, -1));
      const line = Line(1, 1, 3);
      final isPointingAt = segment.pointsAt(line);
      expect(isPointingAt, false, reason: 'Line should not be pointed at');
    });

    test('horizontal line can be pointed at', () {
      final segment = LineSegment(Vector2.zero(), Vector2.all(1));
      const line = Line(0, 1, 2);
      final isPointingAt = segment.pointsAt(line);
      expect(isPointingAt, true, reason: 'Line should be pointed at');
    });

    test('vertical line can be pointed at', () {
      final segment = LineSegment(Vector2.zero(), Vector2.all(1));
      const line = Line(1, 0, 2);
      final isPointingAt = segment.pointsAt(line);
      expect(isPointingAt, true, reason: 'Line should be pointed at');
    });
  });

  group('Polygon intersections tests', () {
    test('simple polygon collision', () {
      final polygonA = Polygon([
        Vector2(2, 2),
        Vector2(3, 1),
        Vector2(2, 0),
        Vector2(1, 1),
      ]);
      final polygonB = Polygon([
        Vector2(1, 2),
        Vector2(2, 1),
        Vector2(1, 0),
        Vector2(0, 1),
      ]);
      final intersections = geometry.intersections(polygonA, polygonB);
      expect(
        intersections.contains(Vector2(1.5, 0.5)),
        true,
        reason: 'Missed one intersection',
      );
      expect(
        intersections.contains(Vector2(1.5, 1.5)),
        true,
        reason: 'Missed one intersection',
      );
      expect(
        intersections.length == 2,
        true,
        reason: 'Wrong number of intersections',
      );
    });

    test('collision on shared line segment', () {
      final polygonA = Polygon([
        Vector2(1, 1),
        Vector2(1, 2),
        Vector2(2, 2),
        Vector2(2, 1),
      ]);
      final polygonB = Polygon([
        Vector2(2, 1),
        Vector2(2, 2),
        Vector2(3, 2),
        Vector2(3, 1),
      ]);
      final intersections = geometry.intersections(polygonA, polygonB);
      expect(
        intersections.containsAll([
          Vector2(2.0, 2.0),
          Vector2(2.0, 1.5),
          Vector2(2.0, 1.0),
        ]),
        true,
        reason: 'Does not have all the correct intersection points',
      );
      expect(
        intersections.length == 3,
        true,
        reason: 'Wrong number of intersections',
      );
    });

    test('one point collision', () {
      final polygonA = Polygon([
        Vector2(1, 1),
        Vector2(1, 2),
        Vector2(2, 2),
        Vector2(2, 1),
      ]);
      final polygonB = Polygon([
        Vector2(2, 2),
        Vector2(2, 3),
        Vector2(3, 3),
        Vector2(3, 2),
      ]);
      final intersections = geometry.intersections(polygonA, polygonB);
      expect(
        intersections.contains(Vector2(2.0, 2.0)),
        true,
        reason: 'Does not have all the correct intersection points',
      );
      expect(
        intersections.length == 1,
        true,
        reason: 'Wrong number of intersections',
      );
    });

    test('collision while no corners are inside the other body', () {
      final polygonA = Polygon.fromDefinition(
        [
          Vector2(1, 1),
          Vector2(1, -1),
          Vector2(-1, -1),
          Vector2(-1, 1),
        ],
        position: Vector2.zero(),
        size: Vector2(2, 4),
      );
      final polygonB = Polygon.fromDefinition(
        [
          Vector2(1, 1),
          Vector2(1, -1),
          Vector2(-1, -1),
          Vector2(-1, 1),
        ],
        position: Vector2.zero(),
        size: Vector2(4, 2),
      );
      final intersections = geometry.intersections(polygonA, polygonB);
      expect(
        intersections.containsAll([
          Vector2(1, 1),
          Vector2(1, -1),
          Vector2(-1, 1),
          Vector2(-1, -1),
        ]),
        true,
        reason: 'Does not have all the correct intersection points',
      );
      expect(
        intersections.length == 4,
        true,
        reason: 'Wrong number of intersections',
      );
    });

    test('collision with advanced hitboxes in different quadrants', () {
      final polygonA = Polygon([
        Vector2(0, 0),
        Vector2(-1, 1),
        Vector2(0, 3),
        Vector2(2, 2),
        Vector2(1.5, 0.5),
      ]);
      final polygonB = Polygon([
        Vector2(-2, -2),
        Vector2(-3, 0),
        Vector2(-2, 3),
        Vector2(1, 2),
        Vector2(2, 1),
      ]);
      final intersections = geometry.intersections(polygonA, polygonB);
      intersections.containsAll([
        Vector2(-0.2857142857142857, 2.4285714285714284),
        Vector2(1.7500000000000002, 1.2500000000000002),
        Vector2(1.5555555555555556, 0.6666666666666667),
        Vector2(1.1999999999999997, 0.39999999999999997),
      ]);
      expect(
        intersections.length == 4,
        true,
        reason: 'Wrong number of intersections',
      );
    });
  });

  group('Rectangle intersections tests', () {
    test('simple intersection', () {
      final rectangleA = Rectangle(
        position: Vector2(4, 0),
        size: Vector2.all(4),
      );
      final rectangleB = Rectangle(
        position: Vector2.zero(),
        size: Vector2.all(4),
      );
      final intersections = geometry.intersections(rectangleA, rectangleB);
      expect(
        intersections.containsAll([
          Vector2(2, -2),
          Vector2(2, 0),
          Vector2(2, 2),
        ]),
        true,
        reason: 'Missed intersections',
      );
      expect(
        intersections.length == 3,
        true,
        reason: 'Wrong number of intersections',
      );
    });
  });

  group('Circle intersections tests', () {
    test('simple collision', () {
      final circleA = Circle.fromDefinition(
        position: Vector2(4, 0),
        size: Vector2.all(4),
      );
      final circleB = Circle.fromDefinition(
        position: Vector2.zero(),
        size: Vector2.all(4),
      );
      final intersections = geometry.intersections(circleA, circleB);
      expect(
        intersections.contains(Vector2(2, 0)),
        true,
        reason: 'Missed one intersection',
      );
      expect(
        intersections.length == 1,
        true,
        reason: 'Wrong number of intersections',
      );
    });

    test('two point collision', () {
      final circleA = Circle.fromDefinition(
        position: Vector2(3, 0),
        size: Vector2.all(4),
      );
      final circleB = Circle.fromDefinition(
        position: Vector2.zero(),
        size: Vector2.all(4),
      );
      final intersections = geometry.intersections(circleA, circleB);
      expect(
        intersections.contains(Vector2(1.5, -1.3228756555322954)),
        true,
        reason: 'Missed one intersection',
      );
      expect(
        intersections.contains(Vector2(1.5, 1.3228756555322954)),
        true,
        reason: 'Missed one intersection',
      );
      expect(
        intersections.length == 2,
        true,
        reason: 'Wrong number of intersections',
      );
    });

    test('same size and position', () {
      final circleA = Circle.fromDefinition(
        position: Vector2.all(3),
        size: Vector2.all(4),
      );
      final circleB = Circle.fromDefinition(
        position: Vector2.all(3),
        size: Vector2.all(4),
      );
      final intersections = geometry.intersections(circleA, circleB);
      expect(
        intersections.containsAll([
          Vector2(5, 3),
          Vector2(3, 5),
          Vector2(3, 1),
          Vector2(1, 3),
        ]),
        true,
        reason: 'Missed intersections',
      );
      expect(
        intersections.length == 4,
        true,
        reason: 'Wrong number of intersections',
      );
    });

    test('not overlapping', () {
      final circleA = Circle.fromDefinition(
        position: Vector2.all(-1),
        size: Vector2.all(4),
      );
      final circleB = Circle.fromDefinition(
        position: Vector2.all(3),
        size: Vector2.all(4),
      );
      final intersections = geometry.intersections(circleA, circleB);
      expect(
        intersections.isEmpty,
        true,
        reason: 'Should not have any intersections',
      );
    });

    test('in third quadrant', () {
      final circleA = Circle.fromDefinition(
        position: Vector2.all(-1),
        size: Vector2.all(2),
      );
      final circleB = Circle.fromDefinition(
        position: Vector2.all(-2),
        size: Vector2.all(2),
      );
      final intersections = geometry.intersections(circleA, circleB).toList();
      expect(
        intersections.any((v) => v.distanceTo(Vector2(-1, -2)) < 0.000001),
        true,
      );
      expect(
        intersections.any((v) => v.distanceTo(Vector2(-2, -1)) < 0.000001),
        true,
      );
      expect(
        intersections.length == 2,
        true,
        reason: 'Wrong number of intersections',
      );
    });

    test('in different quadrants', () {
      final circleA = Circle.fromDefinition(
        position: Vector2.all(-1),
        size: Vector2.all(4),
      );
      final circleB = Circle.fromDefinition(
        position: Vector2.all(1),
        size: Vector2.all(4),
      );
      final intersections = geometry.intersections(circleA, circleB).toList();
      expect(
        intersections.any((v) => v.distanceTo(Vector2(1, -1)) < 0.000001),
        true,
      );
      expect(
        intersections.any((v) => v.distanceTo(Vector2(-1, 1)) < 0.000001),
        true,
      );
      expect(
        intersections.length == 2,
        true,
        reason: 'Wrong number of intersections',
      );
    });
  });

  group('Circle-Polygon intersections tests', () {
    test('simple circle-polygon intersection', () {
      final circle = Circle.fromDefinition(
        position: Vector2.zero(),
        size: Vector2.all(2),
      );
      final polygon = Polygon([
        Vector2(1, 2),
        Vector2(2, 1),
        Vector2(1, 0),
        Vector2(0, 1),
      ]);
      final intersections = geometry.intersections(circle, polygon);
      expect(
        intersections.containsAll([Vector2(0, 1), Vector2(1, 0)]),
        true,
        reason: 'Missed intersections',
      );
      expect(
        intersections.length == 2,
        true,
        reason: 'Wrong number of intersections',
      );
    });

    test('single point circle-polygon intersection', () {
      final circle = Circle.fromDefinition(
        position: Vector2(-1, 1),
        size: Vector2.all(2),
      );
      final polygon = Polygon([
        Vector2(1, 2),
        Vector2(2, 1),
        Vector2(1, 0),
        Vector2(0, 1),
      ]);
      final intersections = geometry.intersections(circle, polygon);
      expect(
        intersections.contains(Vector2(0, 1)),
        true,
        reason: 'Missed intersections',
      );
      expect(
        intersections.length == 1,
        true,
        reason: 'Wrong number of intersections',
      );
    });

    test('four point circle-polygon intersection', () {
      final circle = Circle.fromDefinition(
        position: Vector2.all(1),
        size: Vector2.all(2),
      );
      final polygon = Polygon([
        Vector2(1, 2),
        Vector2(2, 1),
        Vector2(1, 0),
        Vector2(0, 1),
      ]);
      final intersections = geometry.intersections(circle, polygon);
      expect(
        intersections.containsAll([
          Vector2(1, 2),
          Vector2(2, 1),
          Vector2(1, 0),
          Vector2(0, 1),
        ]),
        true,
        reason: 'Missed intersections',
      );
      expect(
        intersections.length == 4,
        true,
        reason: 'Wrong number of intersections',
      );
    });

    test('polygon within circle, no intersections', () {
      final circle = Circle.fromDefinition(
        position: Vector2.all(1),
        size: Vector2.all(2.1),
      );
      final polygon = Polygon([
        Vector2(1, 2),
        Vector2(2, 1),
        Vector2(1, 0),
        Vector2(0, 1),
      ]);
      final intersections = geometry.intersections(circle, polygon);
      expect(
        intersections.isEmpty,
        true,
        reason: 'Should not be any intersections',
      );
    });
  });
}
