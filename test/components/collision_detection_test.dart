import 'package:flame/components.dart';
import 'package:flame/src/collision_detection/collision_detection.dart';
import 'package:flame/src/components/mixins/collidable.dart';
import 'package:flame/src/geometry/line_segment.dart';
import 'package:flame/src/geometry/linear_function.dart';
import 'package:test/test.dart';

class MyCollidableComponent extends PositionComponent with Hitbox, Collidable {
  @override
  List<Vector2> shape = [
    Vector2(0, 1),
    Vector2(1, 0),
    Vector2(0, -1),
    Vector2(-1, 0),
  ];
  bool didCollide = false;

  @override
  void collisionCallback(Set<Vector2> points, Collidable other) {
    didCollide = true;
  }
}

void main() {
  group('LineSegment.isPointOnSegment tests', () {
    test('Can catch simple point', () {
      final segment = LineSegment(
        Vector2.all(0),
        Vector2.all(1),
      );
      final point = Vector2.all(0.5);
      assert(segment.containsPoint(point), "Point should be on segment");
    });

    test('Should not catch point outside of segment', () {
      final segment = LineSegment(
        Vector2.all(0),
        Vector2.all(1),
      );
      final point = Vector2.all(3);
      assert(!segment.containsPoint(point), "Point should not be on segment");
    });

    test('Point on end of segment', () {
      final segment = LineSegment(
        Vector2.all(0),
        Vector2.all(1),
      );
      final point = Vector2.all(1);
      assert(segment.containsPoint(point), "Point should be on segment");
    });

    test('Point on beginning of segment', () {
      final segment = LineSegment(
        Vector2.all(0),
        Vector2.all(1),
      );
      final point = Vector2.all(0);
      assert(segment.containsPoint(point), "Point should be on segment");
    });
  });

  group('LineSegment.intersections tests', () {
    test('Simple intersection', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2(0, 1), Vector2(1, 0));
      final intersection = segmentA.intersections(segmentB);
      assert(intersection.isNotEmpty, "Should have intersection at (0.5, 0.5)");
      assert(intersection.first == Vector2.all(0.5));
    });

    test('No intersection', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2(0, 1), Vector2(1, 2));
      final intersection = segmentA.intersections(segmentB);
      assert(intersection.isEmpty, "Should not have any intersection");
    });

    test('Same line segments', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2.all(0), Vector2.all(1));
      final intersection = segmentA.intersections(segmentB);
      assert(intersection.isNotEmpty, "Should have intersection at (0.5, 0.5)");
      assert(intersection.first == Vector2.all(0.5));
    });

    test('Overlapping line segments', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2.all(0.5), Vector2.all(1.5));
      final intersection = segmentA.intersections(segmentB);
      assert(intersection.isNotEmpty, "Should intersect at (0.75, 0.75)");
      assert(intersection.first == Vector2.all(0.75));
    });

    test('One pixel overlap in different angles', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2.all(0), Vector2(1, -1));
      final intersection = segmentA.intersections(segmentB);
      assert(intersection.isNotEmpty, "Should have intersection at (0, 0)");
      assert(intersection.first == Vector2.all(0));
    });

    test('One pixel parallel overlap in same angle', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2.all(1), Vector2.all(2));
      final intersection = segmentA.intersections(segmentB);
      assert(intersection.isNotEmpty, "Should have intersection at (1, 1)");
      assert(intersection.first == Vector2.all(1));
    });
  });

  group('LinearFunction.intersections tests', () {
    test('Simple line intersection', () {
      const line1 = const LinearFunction(1, -1, 0);
      const line2 = const LinearFunction(1, 1, 0);
      final intersection = line1.intersections(line2);
      assert(intersection.isNotEmpty, 'Should have intersection');
      assert(intersection.first == Vector2.all(0));
    });

    test('Lines with c value', () {
      const line1 = const LinearFunction(1, 1, 1);
      const line2 = const LinearFunction(1, -1, 1);
      final intersection = line1.intersections(line2);
      assert(intersection.isNotEmpty, 'Should have intersection');
      assert(intersection.first == Vector2(1, 0));
    });

    test('Does not catch parallel lines', () {
      const line1 = const LinearFunction(1, 1, -3);
      const line2 = const LinearFunction(1, 1, 6);
      final intersection = line1.intersections(line2);
      assert(intersection.isEmpty, 'Should not have intersection');
    });

    test('Does not catch same line', () {
      const line1 = const LinearFunction(1, 1, 1);
      const line2 = const LinearFunction(1, 1, 1);
      final intersection = line1.intersections(line2);
      assert(intersection.isEmpty, 'Should not have intersection');
    });
  });

  group('LinearEquation.fromPoints tests', () {
    test('Simple line from points', () {
      final line = LinearFunction.fromPoints(Vector2.zero(), Vector2.all(1));
      assert(line.a == 1.0, "a value is not correct");
      assert(line.b == -1.0, "b value is not correct");
      assert(line.c == 0.0, "c value is not correct");
    });

    test('Line not going through origo', () {
      final line = LinearFunction.fromPoints(Vector2(-2, 0), Vector2(0, 2));
      assert(line.a == 2.0, "a value is not correct");
      assert(line.b == -2.0, "b value is not correct");
      assert(line.c == -4.0, "c value is not correct");
    });

    test('Straight vertical line', () {
      final line = LinearFunction.fromPoints(Vector2.all(1), Vector2(1, -1));
      assert(line.a == -2.0, "a value is not correct");
      assert(line.b == 0.0, "b value is not correct");
      assert(line.c == -2.0, "c value is not correct");
    });

    test('Straight horizontal line', () {
      final line = LinearFunction.fromPoints(Vector2.all(1), Vector2(2, 1));
      assert(line.a == 0.0, "a value is not correct");
      assert(line.b == -1.0, "b value is not correct");
      assert(line.c == -1.0, "c value is not correct");
    });
  });

  group('LineSegment.pointsAt tests', () {
    test('Simple pointing', () {
      final segment = LineSegment(Vector2.zero(), Vector2.all(1));
      const line = const LinearFunction(1, 1, 3);
      final isPointingAt = segment.pointsAt(line);
      assert(isPointingAt, 'Line should be pointed at');
    });

    test('Is not pointed at when crossed', () {
      final segment = LineSegment(Vector2.zero(), Vector2.all(3));
      const line = const LinearFunction(1, 1, 3);
      final isPointingAt = segment.pointsAt(line);
      assert(!isPointingAt, 'Line should not be pointed at');
    });

    test('Is not pointed at when parallel', () {
      final segment = LineSegment(Vector2.zero(), Vector2(1, -1));
      const line = const LinearFunction(1, 1, 3);
      final isPointingAt = segment.pointsAt(line);
      assert(!isPointingAt, 'Line should not be pointed at');
    });

    test('Horizonal line can be pointed at', () {
      final segment = LineSegment(Vector2.zero(), Vector2.all(1));
      const line = const LinearFunction(0, 1, 2);
      final isPointingAt = segment.pointsAt(line);
      assert(isPointingAt, 'Line should be pointed at');
    });

    test('Vertical line can be pointed at', () {
      final segment = LineSegment(Vector2.zero(), Vector2.all(1));
      const line = const LinearFunction(1, 0, 2);
      final isPointingAt = segment.pointsAt(line);
      assert(isPointingAt, 'Line should be pointed at');
    });
  });

  group('hitboxIntersections tests', () {
    test('Simple hitbox collision', () {
      final hitboxA = [
        Vector2(2, 2),
        Vector2(3, 1),
        Vector2(2, 0),
        Vector2(1, 1),
      ];
      final hitboxB = [
        Vector2(1, 2),
        Vector2(2, 1),
        Vector2(1, 0),
        Vector2(0, 1),
      ];
      final intersections = hitboxIntersections(hitboxA, hitboxB);
      assert(
        intersections.contains(Vector2(1.5, 0.5)),
        "Missed one intersection",
      );
      assert(
        intersections.contains(Vector2(1.5, 1.5)),
        "Missed one intersection",
      );
      assert(intersections.length == 2, "Wrong number of intersections");
    });

    test('Collision on shared line segment', () {
      final hitboxA = [
        Vector2(1, 1),
        Vector2(1, 2),
        Vector2(2, 2),
        Vector2(2, 1),
      ];
      final hitboxB = [
        Vector2(2, 1),
        Vector2(2, 2),
        Vector2(3, 2),
        Vector2(3, 1),
      ];
      final intersections = hitboxIntersections(hitboxA, hitboxB);
      assert(
          intersections.containsAll(
            [
              Vector2(2.0, 2.0),
              Vector2(2.0, 1.5),
              Vector2(2.0, 1.0),
            ],
          ),
          "Does not have all the correct intersection points");
      assert(intersections.length == 3, "Wrong number of intersections");
    });

    test('One point collision', () {
      final hitboxA = [
        Vector2(1, 1),
        Vector2(1, 2),
        Vector2(2, 2),
        Vector2(2, 1),
      ];
      final hitboxB = [
        Vector2(2, 2),
        Vector2(2, 3),
        Vector2(3, 3),
        Vector2(3, 2),
      ];
      final intersections = hitboxIntersections(hitboxA, hitboxB);
      assert(
        intersections.contains(Vector2(2.0, 2.0)),
        "Does not have all the correct intersection points",
      );
      assert(intersections.length == 1, "Wrong number of intersections");
    });

    test('Collision with advanced hitboxes in different quadrants', () {
      final hitboxA = [
        Vector2(0, 0),
        Vector2(-1, 1),
        Vector2(0, 3),
        Vector2(2, 2),
        Vector2(1.5, 0.5),
      ];
      final hitboxB = [
        Vector2(-2, -2),
        Vector2(-3, 0),
        Vector2(-2, 3),
        Vector2(1, 2),
        Vector2(2, 1),
      ];
      final intersections = hitboxIntersections(hitboxA, hitboxB);
      print(intersections);
      //assert(intersections.contains(Vector2(2.0, 2.0)), "Does not have all the correct intersection points",);
      //assert(intersections.length == 1, "Wrong number of intersections");
    });

    // TODO: Test clockwise vs ccw
  });
}
