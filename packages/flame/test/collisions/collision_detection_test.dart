import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/geometry.dart' as geometry;
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

import 'collision_test_helpers.dart';

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
      final polygonA = PolygonComponent(
        [
          Vector2(2, 2),
          Vector2(3, 1),
          Vector2(2, 0),
          Vector2(1, 1),
        ],
      );
      final polygonB = PolygonComponent(
        [
          Vector2(1, 2),
          Vector2(2, 1),
          Vector2(1, 0),
          Vector2(0, 1),
        ],
      );
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
      final polygonA = PolygonComponent([
        Vector2(1, 1),
        Vector2(1, 2),
        Vector2(2, 2),
        Vector2(2, 1),
      ]);
      final polygonB = PolygonComponent([
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
      final polygonA = PolygonComponent([
        Vector2(1, 1),
        Vector2(1, 2),
        Vector2(2, 2),
        Vector2(2, 1),
      ]);
      final polygonB = PolygonComponent([
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
      final polygonA = PolygonComponent.relative(
        [
          Vector2(1, 1),
          Vector2(1, -1),
          Vector2(-1, -1),
          Vector2(-1, 1),
        ],
        position: Vector2.zero(),
        parentSize: Vector2(2, 4),
      );
      final polygonB = PolygonComponent.relative(
        [
          Vector2(1, 1),
          Vector2(1, -1),
          Vector2(-1, -1),
          Vector2(-1, 1),
        ],
        position: Vector2.zero(),
        parentSize: Vector2(4, 2),
      );
      final intersections = geometry.intersections(polygonA, polygonB);
      expect(
        intersections.containsAll([
          Vector2(2, 0),
          Vector2(2, 2),
          Vector2(1, 0),
          Vector2(0, 0),
          Vector2(0, 1),
          Vector2(0, 2),
        ]),
        true,
        reason: 'Does not have all the correct intersection points',
      );
      expect(
        intersections.length == 6,
        true,
        reason: 'Wrong number of intersections',
      );
    });

    test('collision with advanced hitboxes in different quadrants', () {
      final polygonA = PolygonComponent([
        Vector2(0, 0),
        Vector2(-1, 1),
        Vector2(0, 3),
        Vector2(2, 2),
        Vector2(1.5, 0.5),
      ]);
      final polygonB = PolygonComponent([
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
      final rectangleA = RectangleComponent(
        position: Vector2(4, 0),
        size: Vector2.all(4),
      );
      final rectangleB = RectangleComponent(
        position: Vector2.zero(),
        size: Vector2.all(4),
      );
      final intersections = geometry.intersections(rectangleA, rectangleB);
      expect(
        intersections.containsAll([
          Vector2(4, 0),
          Vector2(4, 2),
          Vector2(4, 4),
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
      final circleA = CircleComponent(radius: 2.0, position: Vector2(4, 0));
      final circleB = CircleComponent(radius: 2.0, position: Vector2.zero());
      final intersections = geometry.intersections(circleA, circleB);
      expect(
        intersections.contains(Vector2(4, 2)),
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
      final circleA = CircleComponent(radius: 2.0, position: Vector2(2, -2));
      final circleB = CircleComponent(radius: 2.0, position: Vector2(0, -2));
      final intersections = geometry.intersections(circleA, circleB).toList();
      expect(
        intersections.contains(Vector2(3.0, -1.7320508075688772)),
        true,
        reason: 'Missed one intersection',
      );
      expect(
        intersections.contains(Vector2(3.0, 1.7320508075688772)),
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
      final circleA = CircleComponent(radius: 4.0, position: Vector2.all(3));
      final circleB = CircleComponent(radius: 4.0, position: Vector2.all(3));
      final intersections = geometry.intersections(circleA, circleB);
      expect(
        intersections.containsAll([
          Vector2(11, 7),
          Vector2(7, 3),
          Vector2(3, 7),
          Vector2(7, 11),
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
      final circleA = CircleComponent(
        radius: 2.0,
        position: Vector2.all(-1),
        anchor: Anchor.center,
      );
      final circleB = CircleComponent(
        radius: 2.0,
        position: Vector2.all(1.83),
        anchor: Anchor.center,
      );
      final intersections = geometry.intersections(circleA, circleB);
      expect(
        intersections.isEmpty,
        true,
        reason: 'Should not have any intersections',
      );
    });

    test('in third quadrant', () {
      final circleA = CircleComponent(
        radius: 1.0,
        position: Vector2.all(-1),
        anchor: Anchor.center,
      );
      final circleB = CircleComponent(
        radius: 1.0,
        position: Vector2.all(-2),
        anchor: Anchor.center,
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
      final circleA = CircleComponent(
        radius: 2.0,
        position: Vector2.all(-1),
        anchor: Anchor.center,
      );
      final circleB = CircleComponent(
        radius: 2.0,
        position: Vector2.all(1),
        anchor: Anchor.center,
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
      final circle = CircleComponent(
        radius: 1.0,
        position: Vector2.zero(),
        anchor: Anchor.center,
      );
      final polygon = PolygonComponent(
        [
          Vector2(1, 2),
          Vector2(2, 1),
          Vector2(1, 0),
          Vector2(0, 1),
        ],
        anchor: Anchor.center,
      );
      final intersections = geometry.intersections(circle, polygon);
      expect(
        intersections.containsAll([Vector2(0, 1), Vector2(1, 0)]),
        true,
        reason: 'Missed intersections',
      );
      expect(intersections.length, 2, reason: 'Wrong number of intersections');
    });

    test('single point circle-polygon intersection', () {
      final circle = CircleComponent(
        radius: 1.0,
        position: Vector2(-1, 1),
        anchor: Anchor.center,
      );
      final polygon = PolygonComponent([
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
      final circle = CircleComponent(
        radius: 1.0,
        position: Vector2.all(1),
        anchor: Anchor.center,
      );
      final polygon = PolygonComponent([
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
      final circle = CircleComponent(
        radius: 1.1,
        position: Vector2.all(1),
        anchor: Anchor.center,
      );
      final polygon = PolygonComponent([
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

  group('Solid intersections', () {
    test('solid circle enclosed by solid circle', () {
      final outerCircle = CircleComponent(
        radius: 4.0,
        anchor: Anchor.center,
      )..isSolid = true;
      final innerCircle = CircleComponent(
        radius: 2.0,
        anchor: Anchor.center,
      )..isSolid = true;
      final intersections = geometry.intersections(outerCircle, innerCircle);
      expect(
        intersections,
        {innerCircle.position},
        reason: "Should return the enclosed circle's position",
      );
    });

    test('solid circle enclosed by hollow circle', () {
      final outerCircle = CircleComponent(
        radius: 4.0,
        anchor: Anchor.center,
      );
      final innerCircle = CircleComponent(
        radius: 2.0,
        anchor: Anchor.center,
      )..isSolid = true;
      final intersections = geometry.intersections(outerCircle, innerCircle);
      expect(
        intersections.isEmpty,
        isTrue,
        reason: 'Should not contain any intersection',
      );
    });

    test('hollow circle enclosed by solid circle', () {
      final outerCircle = CircleComponent(
        radius: 4.0,
        anchor: Anchor.center,
      )..isSolid = true;
      final innerCircle = CircleComponent(
        radius: 2.0,
        anchor: Anchor.center,
      );
      final intersections = geometry.intersections(outerCircle, innerCircle);
      expect(
        intersections,
        {innerCircle.position},
        reason: "Should return the enclosed circle's position",
      );
    });

    test('solid rectangle enclosed by solid rectangle', () {
      final outerRectangle = RectangleComponent(
        size: Vector2.all(4),
        anchor: Anchor.center,
      )..isSolid = true;
      final innerRectangle = RectangleComponent(
        size: Vector2.all(2),
        anchor: Anchor.center,
      )..isSolid = true;
      final intersections =
          geometry.intersections(outerRectangle, innerRectangle);
      expect(
        intersections,
        {innerRectangle.position},
        reason: "Should return the enclosed rectangle's position",
      );
    });

    test('solid rectangle enclosed by hollow rectangle', () {
      final outerRectangle = RectangleComponent(
        size: Vector2.all(4),
        anchor: Anchor.center,
      );
      final innerRectangle = RectangleComponent(
        size: Vector2.all(2),
        anchor: Anchor.center,
      )..isSolid = true;
      final intersections =
          geometry.intersections(outerRectangle, innerRectangle);
      expect(
        intersections.isEmpty,
        isTrue,
        reason: 'Should not contain any intersection',
      );
    });

    test('hollow rectangle enclosed by solid rectangle', () {
      final outerRectangle = RectangleComponent(
        size: Vector2.all(4),
        anchor: Anchor.center,
      )..isSolid = true;
      final innerRectangle = RectangleComponent(
        size: Vector2.all(2),
        anchor: Anchor.center,
      );
      final intersections =
          geometry.intersections(outerRectangle, innerRectangle);
      expect(
        intersections,
        {innerRectangle.position},
        reason: "Should return the enclosed rectangle's position",
      );
    });

    test('solid rectangle with intersections by other solid rectangle', () {
      final rectangleA = RectangleComponent(
        position: Vector2.all(1),
        size: Vector2.all(2),
      )..isSolid = true;
      final rectangleB = RectangleComponent(
        size: Vector2.all(2),
      )..isSolid = true;
      final intersections = geometry.intersections(rectangleA, rectangleB);
      expect(
        intersections,
        {Vector2(1, 2), Vector2(2, 1)},
        reason: "Should return the enclosed rectangle's position",
      );
    });

    testCollisionDetectionGame('circles as children', (game) async {
      final outerCircle = CircleHitbox(
        radius: 4.0,
        anchor: Anchor.center,
      )..isSolid = true;
      final outerContainer = PositionComponent(
        position: Vector2.all(100),
        children: [outerCircle],
      );
      final innerCircle = CircleHitbox(
        radius: 2.0,
        anchor: Anchor.center,
      )..isSolid = true;
      final innerContainer = PositionComponent(
        position: Vector2.all(100),
        children: [innerCircle],
      );
      await game.ensureAddAll([outerContainer, innerContainer]);
      final intersections = game.collisionDetection.intersections(
        innerCircle,
        outerCircle,
      );
      expect(
        intersections,
        {innerCircle.absolutePosition},
        reason: "Should return the enclosed circle's position",
      );
    });

    test('solid circle enclosed by solid polygon', () {
      final outerPolygon = PolygonComponent(
        [
          Vector2(5, 1),
          Vector2(1, 1),
          Vector2(1, 5),
          Vector2(6, 5),
        ],
      )..isSolid = true;
      final innerCircle = CircleComponent(
        position: Vector2.all(3),
        radius: 1.5,
        anchor: Anchor.center,
      )..isSolid = true;
      final intersections = geometry.intersections(outerPolygon, innerCircle);
      expect(
        intersections,
        {innerCircle.position},
        reason: "Should return the enclosed circle's position",
      );
    });

    test('solid circle enclosed by hollow polygon', () {
      final outerPolygon = PolygonComponent(
        [
          Vector2(5, 1),
          Vector2(1, 1),
          Vector2(1, 5),
          Vector2(6, 5),
        ],
      );
      final innerCircle = CircleComponent(
        position: Vector2.all(3),
        radius: 1.5,
        anchor: Anchor.center,
      )..isSolid = true;
      final intersections = geometry.intersections(outerPolygon, innerCircle);
      expect(
        intersections.isEmpty,
        isTrue,
        reason: 'Should not contain any intersection',
      );
    });

    test('hollow circle enclosed by solid polygon', () {
      final outerPolygon = PolygonComponent(
        [
          Vector2(5, 1),
          Vector2(1, 1),
          Vector2(1, 5),
          Vector2(6, 5),
        ],
      )..isSolid = true;
      final innerCircle = CircleComponent(
        position: Vector2.all(3),
        radius: 1.5,
        anchor: Anchor.center,
      );
      final intersections = geometry.intersections(outerPolygon, innerCircle);
      expect(
        intersections,
        {innerCircle.position},
        reason: "Should return the enclosed circle's position",
      );
    });

    test('solid polygon enclosed by solid circle', () {
      final outerCircle = CircleComponent(
        position: Vector2.all(3),
        radius: 3,
        anchor: Anchor.center,
      )..isSolid = true;
      final innerPolygon = PolygonComponent(
        [
          Vector2(4, 2),
          Vector2(2, 2),
          Vector2(2, 4),
          Vector2(4.5, 4.5),
        ],
        anchor: Anchor.center,
      )..isSolid = true;
      final intersections = geometry.intersections(outerCircle, innerPolygon);
      expect(
        intersections,
        {innerPolygon.position},
        reason: "Should return the enclosed polygon's position",
      );
    });

    test('solid polygon enclosed by hollow circle', () {
      final outerCircle = CircleComponent(
        position: Vector2.all(3),
        radius: 3,
        anchor: Anchor.center,
      );
      final innerPolygon = PolygonComponent(
        [
          Vector2(4, 2),
          Vector2(2, 2),
          Vector2(2, 4),
          Vector2(4.5, 4.5),
        ],
        anchor: Anchor.center,
      )..isSolid = true;
      final intersections = geometry.intersections(outerCircle, innerPolygon);
      expect(
        intersections.isEmpty,
        isTrue,
        reason: 'Should not contain any intersection',
      );
    });

    test('hollow polygon enclosed by solid circle', () {
      final outerCircle = CircleComponent(
        position: Vector2.all(3),
        radius: 3,
        anchor: Anchor.center,
      )..isSolid = true;
      final innerPolygon = PolygonComponent(
        [
          Vector2(4, 2),
          Vector2(2, 2),
          Vector2(2, 4),
          Vector2(4.5, 4.5),
        ],
        anchor: Anchor.center,
      );
      final intersections = geometry.intersections(outerCircle, innerPolygon);
      expect(
        intersections,
        {innerPolygon.position},
        reason: "Should return the enclosed polygon's position",
      );
    });
  });

  group('Raycasting', () {
    runCollisionTestRegistry({
      'one hitbox': (game) async {
        game.ensureAdd(
          PositionComponent(
            children: [RectangleHitbox()],
            position: Vector2(100, 0),
            size: Vector2.all(100),
            anchor: Anchor.center,
          ),
        );
        await game.ready();

        final ray = Ray2(
          origin: Vector2.zero(),
          direction: Vector2(1, 0),
        );
        final result = game.collisionDetection.raycast(ray);
        expect(result?.hitbox?.parent, game.children.first);
        expect(result?.reflectionRay?.origin, closeToVector(Vector2(50, 0)));
        expect(result?.reflectionRay?.direction, closeToVector(Vector2(-1, 0)));
      },
      'multiple hitboxes after each other': (game) async {
        game.ensureAddAll([
          for (var i = 0.0; i < 10; i++)
            PositionComponent(
              position: Vector2.all(100 + i * 10),
              size: Vector2.all(20 - i),
              anchor: Anchor.center,
            )..add(RectangleHitbox()),
        ]);
        await game.ready();
        final ray = Ray2(
          origin: Vector2.zero(),
          direction: Vector2.all(1)..normalize(),
        );
        final result = game.collisionDetection.raycast(ray);
        expect(result?.hitbox?.parent, game.children.first);
        expect(result?.reflectionRay?.origin, closeToVector(Vector2.all(90)));
        expect(
          result?.reflectionRay?.direction,
          closeToVector(Vector2(-1, 1)..normalize()),
        );
      },
      'multiple hitboxes after each other with one ignored': (game) async {
        game.ensureAddAll([
          for (var i = 0.0; i < 10; i++)
            PositionComponent(
              position: Vector2.all(100 + i * 10),
              size: Vector2.all(20 - i),
              anchor: Anchor.center,
            )..add(RectangleHitbox()),
        ]);
        await game.ready();
        final ray = Ray2(
          origin: Vector2.zero(),
          direction: Vector2.all(1)..normalize(),
        );
        final result = game.collisionDetection.raycast(
          ray,
          ignoreHitboxes: [
            game.children.first.children.first as ShapeHitbox,
          ],
        );
        expect(result?.hitbox?.parent, game.children.toList()[1]);
        expect(
          result?.reflectionRay?.origin,
          closeToVector(Vector2.all(100.5)),
        );
        expect(
          result?.reflectionRay?.direction,
          closeToVector(Vector2(-1, 1)..normalize()),
        );
      },
      'ray with origin on hitbox corner': (game) async {
        game.ensureAddAll([
          PositionComponent(
            position: Vector2.all(10),
            size: Vector2.all(10),
          )..add(RectangleHitbox()),
        ]);
        await game.ready();
        final ray = Ray2(
          origin: Vector2.all(10),
          direction: Vector2.all(1)..normalize(),
        );
        final result = game.collisionDetection.raycast(ray);
        expect(result?.hitbox?.parent, game.children.first);
        expect(result?.reflectionRay?.origin, closeToVector(Vector2(20, 20)));
        expect(
          result?.reflectionRay?.direction,
          closeToVector(Vector2(1, -1)..normalize()),
        );
      },
      'raycast with maxDistance': (game) async {
        game.ensureAddAll([
          PositionComponent(
            position: Vector2.all(20),
            size: Vector2.all(40),
            children: [RectangleHitbox()],
          ),
        ]);
        await game.ready();
        final ray = Ray2(
          origin: Vector2.all(10),
          direction: Vector2.all(1)..normalize(),
        );

        final result = RaycastResult<ShapeHitbox>();

        // No hit cast
        game.collisionDetection.raycast(
          ray,
          maxDistance: Vector2.all(9).length,
          out: result,
        );
        expect(result.hitbox?.parent, isNull);

        // Extended cast
        game.collisionDetection.raycast(
          ray,
          maxDistance: Vector2.all(10).length,
          out: result,
        );
        expect(result.hitbox?.parent, game.children.first);
      },
    });

    group('Rectangle hitboxes', () {
      runCollisionTestRegistry({
        'ray from within RectangleHitbox': (game) async {
          game.ensureAddAll([
            PositionComponent(
              position: Vector2.all(0),
              size: Vector2.all(10),
            )..add(RectangleHitbox()),
          ]);
          await game.ready();
          final ray = Ray2(
            origin: Vector2.all(5),
            direction: Vector2.all(1)..normalize(),
          );
          final result = game.collisionDetection.raycast(ray);
          expect(result?.hitbox?.parent, game.children.first);
          expect(result?.normal, closeToVector(Vector2(0, -1)));
          expect(result?.reflectionRay?.origin, closeToVector(Vector2(10, 10)));
          expect(
            result?.reflectionRay?.direction,
            closeToVector(Vector2(1, -1)..normalize()),
          );
        },
        'ray from the left of RectangleHitbox': (game) async {
          game.ensureAddAll([
            PositionComponent(
              position: Vector2.zero(),
              size: Vector2.all(10),
            )..add(RectangleHitbox()),
          ]);
          await game.ready();
          final ray = Ray2(origin: Vector2(-5, 5), direction: Vector2(1, 0));
          final result = game.collisionDetection.raycast(ray);
          expect(result?.hitbox?.parent, game.children.first);
          expect(result?.reflectionRay?.origin, closeToVector(Vector2(0, 5)));
          expect(
            result?.reflectionRay?.direction,
            closeToVector(Vector2(-1, 0)),
          );
        },
        'ray from the top of RectangleHitbox': (game) async {
          game.ensureAddAll([
            PositionComponent(
              position: Vector2.zero(),
              size: Vector2.all(10),
            )..add(RectangleHitbox()),
          ]);
          await game.ready();
          final ray = Ray2(origin: Vector2(5, -5), direction: Vector2(0, 1));
          final result = game.collisionDetection.raycast(ray);
          expect(result?.hitbox?.parent, game.children.first);
          expect(result?.reflectionRay?.origin, closeToVector(Vector2(5, 0)));
          expect(
            result?.reflectionRay?.direction,
            closeToVector(Vector2(0, -1)),
          );
        },
        'ray from the right of RectangleHitbox': (game) async {
          game.ensureAddAll([
            PositionComponent(
              position: Vector2.zero(),
              size: Vector2.all(10),
            )..add(RectangleHitbox()),
          ]);
          await game.ready();
          final ray = Ray2(origin: Vector2(15, 5), direction: Vector2(-1, 0));
          final result = game.collisionDetection.raycast(ray);
          expect(result?.hitbox?.parent, game.children.first);
          expect(result?.reflectionRay?.origin, closeToVector(Vector2(10, 5)));
          expect(
            result?.reflectionRay?.direction,
            closeToVector(Vector2(1, 0)),
          );
        },
        'ray from the bottom of RectangleHitbox': (game) async {
          game.ensureAddAll([
            PositionComponent(
              position: Vector2.zero(),
              size: Vector2.all(10),
            )..add(RectangleHitbox()),
          ]);
          await game.ready();
          final ray = Ray2(origin: Vector2(5, 15), direction: Vector2(0, -1));
          final result = game.collisionDetection.raycast(ray);
          expect(result?.hitbox?.parent, game.children.first);
          expect(result?.reflectionRay?.origin, closeToVector(Vector2(5, 10)));
          expect(
            result?.reflectionRay?.direction,
            closeToVector(Vector2(0, 1)),
          );
        },
      });
    });

    group('Circle hitboxes', () {
      runCollisionTestRegistry({
        'ray from top to bottom within CircleHitbox': (game) async {
          game.ensureAddAll([
            PositionComponent(
              position: Vector2.zero(),
              size: Vector2.all(10),
            )..add(CircleHitbox()),
          ]);
          await game.ready();
          final ray = Ray2(origin: Vector2(5, 4), direction: Vector2(0, 1));
          final result = game.collisionDetection.raycast(ray);
          expect(result?.hitbox?.parent, game.children.first);
          expect(result?.normal, closeToVector(Vector2(0, -1)));
          expect(result?.reflectionRay?.origin, closeToVector(Vector2(5, 10)));
          expect(
            result?.reflectionRay?.direction,
            closeToVector(Vector2(0, -1)),
          );
        },
        'ray from bottom-right to top-left within CircleHitbox': (game) async {
          game.ensureAddAll([
            PositionComponent(
              position: Vector2.zero(),
              size: Vector2.all(10),
            )..add(CircleHitbox()),
          ]);
          await game.ready();
          final ray = Ray2(
            origin: Vector2.all(6),
            direction: Vector2.all(-1)..normalize(),
          );
          final result = game.collisionDetection.raycast(ray);
          expect(result?.hitbox?.parent, game.children.first);
          expect(result?.normal, closeToVector(Vector2.all(0.707106781186547)));
          expect(
            result?.intersectionPoint,
            closeToVector(Vector2.all(1.4644660940672631)),
          );
          expect(
            result?.reflectionRay?.direction,
            closeToVector(Vector2.all(1)..normalize()),
          );
        },
        'ray from bottom within CircleHitbox going down': (game) async {
          game.ensureAddAll([
            PositionComponent(
              position: Vector2.zero(),
              size: Vector2.all(10),
            )..add(CircleHitbox()),
          ]);
          await game.ready();
          final direction = Vector2(0, 1);
          final ray = Ray2(origin: Vector2(5, 6), direction: direction);
          final result = game.collisionDetection.raycast(ray);
          expect(result?.hitbox?.parent, game.children.first);
          expect(result?.normal, closeToVector(Vector2(0, -1)));
          expect(
            result?.intersectionPoint,
            closeToVector(Vector2(5, 10)),
          );
          expect(
            result?.reflectionRay?.direction,
            closeToVector(direction.inverted()),
          );
        },
        'ray from the left of CircleHitbox': (game) async {
          game.ensureAddAll([
            PositionComponent(
              position: Vector2.zero(),
              size: Vector2.all(10),
            )..add(CircleHitbox()),
          ]);
          await game.ready();
          final ray = Ray2(origin: Vector2(-5, 5), direction: Vector2(1, 0));
          final result = game.collisionDetection.raycast(ray);
          expect(result?.hitbox?.parent, game.children.first);
          expect(result?.reflectionRay?.origin, closeToVector(Vector2(0, 5)));
          expect(
            result?.reflectionRay?.direction,
            closeToVector(Vector2(-1, 0)),
          );
        },
        'ray from the top of CircleHitbox': (game) async {
          game.ensureAddAll([
            PositionComponent(
              position: Vector2.zero(),
              size: Vector2.all(10),
            )..add(CircleHitbox()),
          ]);
          await game.ready();
          final ray = Ray2(origin: Vector2(5, -5), direction: Vector2(0, 1));
          final result = game.collisionDetection.raycast(ray);
          expect(result?.hitbox?.parent, game.children.first);
          expect(result?.reflectionRay?.origin, closeToVector(Vector2(5, 0)));
          expect(
            result?.reflectionRay?.direction,
            closeToVector(Vector2(0, -1)),
          );
        },
        'ray from the right of CircleHitbox': (game) async {
          game.ensureAddAll([
            PositionComponent(
              position: Vector2.zero(),
              size: Vector2.all(10),
            )..add(CircleHitbox()),
          ]);
          await game.ready();
          final ray = Ray2(origin: Vector2(15, 5), direction: Vector2(-1, 0));
          final result = game.collisionDetection.raycast(ray);
          expect(result?.hitbox?.parent, game.children.first);
          expect(result?.reflectionRay?.origin, closeToVector(Vector2(10, 5)));
          expect(
            result?.reflectionRay?.direction,
            closeToVector(Vector2(1, 0)),
          );
        },
        'ray from the bottom of CircleHitbox': (game) async {
          game.ensureAddAll([
            PositionComponent(
              position: Vector2.zero(),
              size: Vector2.all(10),
            )..add(CircleHitbox()),
          ]);
          await game.ready();
          final ray = Ray2(origin: Vector2(5, 15), direction: Vector2(0, -1));
          final result = game.collisionDetection.raycast(ray);
          expect(result?.hitbox?.parent, game.children.first);
          expect(result?.reflectionRay?.origin, closeToVector(Vector2(5, 10)));
          expect(
            result?.reflectionRay?.direction,
            closeToVector(Vector2(0, 1)),
          );
        },
        'ray from the center of CircleHitbox': (game) async {
          final positionComponent = PositionComponent(
            position: Vector2.zero(),
            size: Vector2.all(10),
          )..add(CircleHitbox());
          game.ensureAdd(positionComponent);

          await game.ready();
          final ray = Ray2(
            origin: positionComponent.absoluteCenter,
            direction: Vector2(0, -1),
          );
          final result = game.collisionDetection.raycast(ray);
          expect(result?.hitbox?.parent, positionComponent);
          expect(result?.reflectionRay?.origin, closeToVector(Vector2(5, 0)));
          expect(
            result?.reflectionRay?.direction,
            closeToVector(Vector2(0, 1)),
          );
        },
      });
    });

    group('raycastAll', () {
      runCollisionTestRegistry({
        'All directions and all hits': (game) async {
          game.ensureAddAll([
            PositionComponent(
              position: Vector2(10, 0),
              size: Vector2.all(10),
            )..add(RectangleHitbox()),
            PositionComponent(
              position: Vector2(20, 10),
              size: Vector2.all(10),
            )..add(RectangleHitbox()),
            PositionComponent(
              position: Vector2(10, 20),
              size: Vector2.all(10),
            )..add(RectangleHitbox()),
            PositionComponent(
              position: Vector2(0, 10),
              size: Vector2.all(10),
            )..add(RectangleHitbox()),
          ]);
          await game.ready();
          final origin = Vector2.all(15);
          final results = game.collisionDetection.raycastAll(
            origin,
            numberOfRays: 4,
          );
          expect(results.every((r) => r.isActive), isTrue);
          expect(results.length, 4);
        },
        'raycastAll with maxDistance': (game) async {
          game.ensureAddAll([
            PositionComponent(
              position: Vector2(10, 0),
              size: Vector2.all(10),
            )..add(RectangleHitbox()),
            PositionComponent(
              position: Vector2(20, 10),
              size: Vector2.all(10),
            )..add(RectangleHitbox()),
            PositionComponent(
              position: Vector2(10, 20),
              size: Vector2.all(10),
            )..add(RectangleHitbox()),
            PositionComponent(
              position: Vector2(0, 10),
              size: Vector2.all(10),
            )..add(RectangleHitbox()),
          ]);
          await game.ready();
          final origin = Vector2.all(15);

          // No hit
          final results1 = game.collisionDetection.raycastAll(
            origin,
            maxDistance: 4,
            numberOfRays: 4,
          );
          expect(results1.length, isZero);

          // Hit all four
          final results2 = game.collisionDetection.raycastAll(
            origin,
            maxDistance: 5,
            numberOfRays: 4,
          );
          expect(results2.length, 4);
        },
      });
    });

    runCollisionTestRegistry({
      'All directions and all hits': (game) async {
        game.ensureAddAll([
          PositionComponent(
            position: Vector2(10, 0),
            size: Vector2.all(10),
          )..add(RectangleHitbox()),
          PositionComponent(
            position: Vector2(20, 10),
            size: Vector2.all(10),
          )..add(RectangleHitbox()),
          PositionComponent(
            position: Vector2(10, 20),
            size: Vector2.all(10),
          )..add(RectangleHitbox()),
          PositionComponent(
            position: Vector2(0, 10),
            size: Vector2.all(10),
          )..add(RectangleHitbox()),
        ]);
        await game.ready();
        final origin = Vector2.all(15);
        final ignoreHitbox = game.children.first.children.first as ShapeHitbox;
        final results = game.collisionDetection.raycastAll(
          origin,
          numberOfRays: 4,
          ignoreHitboxes: [ignoreHitbox],
        );
        expect(results.any((r) => r.hitbox == ignoreHitbox), isFalse);
        expect(results.every((r) => r.isActive), isTrue);
        expect(results.length, 3);
      },
    });
  });

  group('Raytracing', () {
    runCollisionTestRegistry({
      'on single circle': (game) async {
        final circle = CircleComponent(
          radius: 10.0,
          position: Vector2.all(20),
          anchor: Anchor.center,
        )..add(CircleHitbox());
        await game.ensureAdd(circle);
        final ray = Ray2(
          origin: Vector2(0, 10),
          direction: Vector2.all(1.0)..normalize(),
        );
        final results = game.collisionDetection.raytrace(ray);
        expect(results.length, 1);
        expect(results.first.isActive, isTrue);
        expect(results.first.isInsideHitbox, isFalse);
        expect(results.first.intersectionPoint, Vector2(10, 20));
        final reflectionRay = results.first.reflectionRay;
        expect(reflectionRay?.origin, Vector2(10, 20));
        expect(reflectionRay?.direction, Vector2(-1, 1)..normalize());
        expect(results.first.normal, Vector2(-1, 0));
      },
      'on single rectangle': (game) async {
        final rectangle = RectangleComponent(
          position: Vector2.all(20),
          size: Vector2.all(20),
          anchor: Anchor.center,
        )..add(RectangleHitbox());
        await game.ensureAdd(rectangle);
        final ray = Ray2(
          origin: Vector2(0, 10),
          direction: Vector2.all(1.0)..normalize(),
        );
        final results = game.collisionDetection.raytrace(ray);
        expect(results.length, 1);
        expect(results.first.isActive, isTrue);
        expect(results.first.isInsideHitbox, isFalse);
        expect(results.first.intersectionPoint, Vector2(10, 20));
        final reflectionRay = results.first.reflectionRay;
        expect(reflectionRay?.origin, Vector2(10, 20));
        expect(reflectionRay?.direction, Vector2(-1, 1)..normalize());
        expect(results.first.normal, Vector2(-1, 0));
      },
      'on single rectangle with ray with negative X': (game) async {
        final rectangle = RectangleComponent(
          position: Vector2(-20, 40),
          size: Vector2.all(20),
          anchor: Anchor.center,
        )..add(RectangleHitbox());
        await game.ensureAdd(rectangle);
        final ray = Ray2(
          origin: Vector2(10, 20),
          direction: Vector2(-1, 1)..normalize(),
        );
        final results = game.collisionDetection.raytrace(ray);
        expect(results.length, 1);
        expect(results.first.isActive, isTrue);
        expect(results.first.isInsideHitbox, isFalse);
        expect(results.first.intersectionPoint, Vector2(-10, 40));
        final reflectionRay = results.first.reflectionRay;
        expect(reflectionRay?.origin, Vector2(-10, 40));
        expect(reflectionRay?.direction, Vector2(1, 1)..normalize());
        expect(results.first.normal, Vector2(1, 0));
      },
      'on two circles': (game) async {
        final circle1 = CircleComponent(
          position: Vector2.all(20),
          radius: 10,
          anchor: Anchor.center,
        )..add(CircleHitbox());
        final circle2 = CircleComponent(
          position: Vector2(-20, 40),
          radius: 10,
          anchor: Anchor.center,
        )..add(CircleHitbox());
        await game.ensureAddAll([circle1, circle2]);
        final ray = Ray2(
          origin: Vector2(0, 10),
          direction: Vector2.all(1.0)..normalize(),
        );
        final results = game.collisionDetection.raytrace(ray).toList();
        expect(results.length, 2);
        expect(results.every((e) => e.isActive), isTrue);
        expect(results.every((e) => e.isInsideHitbox), isFalse);
        // First box
        expect(results[0].intersectionPoint, Vector2(10, 20));
        expect(results[0].normal, Vector2(-1, 0));
        final reflectionRay1 = results[0].reflectionRay;
        expect(reflectionRay1?.origin, Vector2(10, 20));
        expect(reflectionRay1?.direction, Vector2(-1, 1)..normalize());
        final results2 = game.collisionDetection.raytrace(reflectionRay1!);
        expect(results2.length, 1);
        // Second box
        expect(results[1].intersectionPoint, Vector2(-10, 40));
        expect(results[1].normal, Vector2(1, 0));
        final reflectionRay2 = results[1].reflectionRay;
        expect(reflectionRay2?.origin, Vector2(-10, 40));
        expect(reflectionRay2?.direction, Vector2(1, 1)..normalize());
      },
      'on two rectangles': (game) async {
        final rectangle1 = RectangleComponent(
          position: Vector2.all(20),
          size: Vector2.all(20),
          anchor: Anchor.center,
        )..add(RectangleHitbox());
        final rectangle2 = RectangleComponent(
          position: Vector2(-20, 40),
          size: Vector2.all(20),
          anchor: Anchor.center,
        )..add(RectangleHitbox());
        await game.ensureAddAll([rectangle1, rectangle2]);
        final ray = Ray2(
          origin: Vector2(0, 10),
          direction: Vector2.all(1.0)..normalize(),
        );
        final results = game.collisionDetection.raytrace(ray).toList();
        expect(results.length, 2);
        expect(results.every((e) => e.isActive), isTrue);
        expect(results.every((e) => e.isInsideHitbox), isFalse);
        // First box
        expect(results[0].intersectionPoint, Vector2(10, 20));
        expect(results[0].normal, Vector2(-1, 0));
        final reflectionRay1 = results[0].reflectionRay;
        expect(reflectionRay1?.origin, Vector2(10, 20));
        expect(reflectionRay1?.direction, Vector2(-1, 1)..normalize());
        final results2 =
            game.collisionDetection.raytrace(reflectionRay1!).toList();
        expect(results2.length, 1);
        // Second box
        expect(results[1].intersectionPoint, Vector2(-10, 40));
        expect(results[1].normal, Vector2(1, 0));
        final reflectionRay2 = results[1].reflectionRay;
        expect(reflectionRay2?.origin, Vector2(-10, 40));
        expect(reflectionRay2?.direction, Vector2(1, 1)..normalize());
      },
      'on two rectangles with one ignored': (game) async {
        final rectangle1 = RectangleComponent(
          position: Vector2.all(20),
          size: Vector2.all(20),
          anchor: Anchor.center,
        )..add(RectangleHitbox());
        final rectangle2 = RectangleComponent(
          position: Vector2(-20, 40),
          size: Vector2.all(20),
          anchor: Anchor.center,
        )..add(RectangleHitbox());
        await game.ensureAddAll([rectangle1, rectangle2]);
        final ray = Ray2(
          origin: Vector2(0, 10),
          direction: Vector2.all(1.0)..normalize(),
        );
        final ignoreHitbox =
            game.children.toList()[1].children.first as ShapeHitbox;
        final results = game.collisionDetection
            .raytrace(ray, ignoreHitboxes: [ignoreHitbox]).toList();
        expect(results.length, 1);
        expect(results.every((e) => e.isActive), isTrue);
        expect(results.every((e) => e.isInsideHitbox), isFalse);
        // First box
        expect(results[0].intersectionPoint, Vector2(10, 20));
        expect(results[0].normal, Vector2(-1, 0));
        final reflectionRay1 = results[0].reflectionRay;
        expect(reflectionRay1?.origin, Vector2(10, 20));
        expect(reflectionRay1?.direction, Vector2(-1, 1)..normalize());
        final results2 =
            game.collisionDetection.raytrace(reflectionRay1!).toList();
        expect(results2.length, 1);
      },
      'on a rectangle within another': (game) async {
        final rectangle1 = RectangleComponent(
          position: Vector2.all(20),
          size: Vector2.all(20),
        )..add(RectangleHitbox());
        final rectangle2 = RectangleComponent(
          size: Vector2.all(200),
        )..add(RectangleHitbox());
        await game.ensureAddAll([rectangle1, rectangle2]);
        final ray = Ray2(
          origin: Vector2(20, 10),
          direction: Vector2.all(1.0)..normalize(),
        );
        final results = game.collisionDetection.raytrace(ray).toList();
        expect(results.length, 10);
        expect(results.every((e) => e.isActive), isTrue);
        expect(results[0].isInsideHitbox, isFalse);
        expect(results[1].isInsideHitbox, isTrue);
        // First box
        expect(results[0].intersectionPoint, Vector2(30, 20));
        expect(results[0].normal, Vector2(0, -1));
        final reflectionRay1 = results[0].reflectionRay;
        expect(reflectionRay1?.origin, Vector2(30, 20));
        expect(reflectionRay1?.direction, Vector2(1, -1)..normalize());
        final results2 =
            game.collisionDetection.raytrace(reflectionRay1!).toList();
        expect(results2.length, 10);
        // Second box
        expect(results[1].intersectionPoint, Vector2(50, 0));
        expect(results[1].normal, Vector2(0, 1));
        final reflectionRay2 = results[1].reflectionRay;
        expect(reflectionRay2?.origin, Vector2(50, 0));
        expect(reflectionRay2?.direction, Vector2(1, 1)..normalize());
      }
    });
  });
}
