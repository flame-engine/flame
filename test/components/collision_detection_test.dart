import 'dart:math' as math;

import 'package:flame/anchor.dart';
import 'package:flame/collision_detection.dart';
import 'package:flame/components/mixins/collidable.dart';
import 'package:flame/components/mixins/hitbox.dart';
import 'package:flame/components/position_component.dart';
import 'package:flame/extensions/vector2.dart';
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
  void collisionCallback(List<Vector2> points, Collidable other) {
    didCollide = true;
  }
}

void main() {
  group('isPointOnSegment tests', () {
    test('Can catch simple point', () {
      final a = Vector2.all(0);
      final b = Vector2.all(1);
      final point = Vector2.all(0.5);
      assert(isPointOnSegment(point, a, b), "Point should be on segment");
    });

    test('Should not catch point outside of segment', () {
      final a = Vector2.all(0);
      final b = Vector2.all(1);
      final point = Vector2.all(3);
      assert(!isPointOnSegment(point, a, b), "Point should not be on segment");
    });

    test('Can catch point on end of segment', () {
      final a = Vector2.all(0);
      final b = Vector2.all(1);
      final point = Vector2.all(1);
      assert(isPointOnSegment(point, a, b), "Point should be on segment");
    });

    test('Can catch point on beginning of segment', () {
      final a = Vector2.all(0);
      final b = Vector2.all(1);
      final point = Vector2.all(0);
      assert(isPointOnSegment(point, a, b), "Point should be on segment");
    });
  });
    
  group('lineSegmentIntersection tests', () {
    test('Can catch simple intersection', () {
      final intersection = lineSegmentIntersection(
        Vector2(0, 0),
        Vector2(1, 1),
        Vector2(0, 1),
        Vector2(1, 0),
      );
      assert(intersection.isNotEmpty, "Should have intersection at (0.5, 0.5)");
      assert(intersection.first == Vector2.all(0.5));
    });

    test('Can handle no intersection', () {
      final intersection = lineSegmentIntersection(
        Vector2(0, 0),
        Vector2(1, 1),
        Vector2(0, 1),
        Vector2(1, 2),
      );
      assert(intersection.isEmpty, "Should not have any intersection");
    });

    test('Can catch same line segments', () {
      final intersection = lineSegmentIntersection(
        Vector2(0, 0),
        Vector2(1, 1),
        Vector2(0, 0),
        Vector2(1, 1),
      );
      assert(intersection.isNotEmpty, "Should intersect at (0.5, 0.5)");
      assert(intersection.first == Vector2.all(0.5));
    });

    test('Can catch overlapping line segments', () {
      final intersection = lineSegmentIntersection(
        Vector2(0.0, 0.0),
        Vector2(1.0, 1.0),
        Vector2(0.5, 0.5),
        Vector2(1.5, 1.5),
      );
      assert(intersection.isNotEmpty, "Should intersect at (0.75, 0.75)");
      assert(intersection.first == Vector2.all(0.75));
    });

    test('Can catch one pixel overlap', () {
      final intersection = lineSegmentIntersection(
        Vector2(0, 0),
        Vector2(1, 1),
        Vector2(0, 0),
        Vector2(1, -1),
      );
      assert(intersection.isNotEmpty, "Should have intersection at (0, 0)");
      assert(intersection.first == Vector2.all(0));
    });

    test('Can catch one pixel parallel overlap', () {
      final intersection = lineSegmentIntersection(
        Vector2(0, 0),
        Vector2(1, 1),
        Vector2(1, 1),
        Vector2(2, 2),
      );
      assert(intersection.isNotEmpty, "Should have intersection at (1, 1)");
      assert(intersection.first == Vector2.all(1));
    });
  });

  group('lineIntersection tests', () {
    test('Can catch simple line intersection', () {
      const line1 = const LinearFunction(1, -1, 0);
      const line2 = const LinearFunction(1, 1, 0);
      final intersection = lineIntersection(line1, line2);
      assert(intersection.isNotEmpty, 'Should have intersection');
      assert(intersection.first == Vector2.all(0));
    });

    test('Can catch lines with c value', () {
      const line1 = const LinearFunction(1, 1, 1);
      const line2 = const LinearFunction(1, -1, 1);
      final intersection = lineIntersection(line1, line2);
      assert(intersection.isNotEmpty, 'Should have intersection');
      assert(intersection.first == Vector2(1, 0));
    });

    test('Does not catch parallel lines', () {
      const line1 = const LinearFunction(1, 1, -3);
      const line2 = const LinearFunction(1, 1, 6);
      final intersection = lineIntersection(line1, line2);
      assert(intersection.isEmpty, 'Should not have intersection');
    });
    
    test('Does not catch same line', () {
      const line1 = const LinearFunction(1, 1, 1);
      const line2 = const LinearFunction(1, 1, 1);
      final intersection = lineIntersection(line1, line2);
      assert(intersection.isEmpty, 'Should not have intersection');
    });
  });

  group('LinearEquation.fromPoints tests', () {
    test('Can create simple line from points', () {
      final line = LinearFunction.fromPoints(Vector2.zero(), Vector2.all(1));
      assert(line.a == 1.0, "a value is not correct");
      assert(line.b == -1.0, "b value is not correct");
      assert(line.c == 0.0, "c value is not correct");
    });

    test('Can create line not going through origo', () {
      final line = LinearFunction.fromPoints(Vector2(-2, 0), Vector2(0, 2));
      assert(line.a == 2.0, "a value is not correct");
      assert(line.b == -2.0, "b value is not correct");
      assert(line.c == -4.0, "c value is not correct");
    });
    
    test('Can create straight vertical line', () {
      final line = LinearFunction.fromPoints(Vector2.all(1), Vector2(1, -1));
      assert(line.a == -2.0, "a value is not correct");
      assert(line.b == 0.0, "b value is not correct");
      assert(line.c == -2.0, "c value is not correct");
    });

    test('Can create straight horizontal line', () {
      final line = LinearFunction.fromPoints(Vector2.all(1), Vector2(2, 1));
      assert(line.a == 0.0, "a value is not correct");
      assert(line.b == -1.0, "b value is not correct");
      assert(line.c == -1.0, "c value is not correct");
    });
  });
  
  group('LinearEquation.isPointedAt tests', () {
    test('Can catch simple pointing', () {
      const line = const LinearFunction(1, 1, 3);
      final from = Vector2.zero();
      final through = Vector2.all(1);
      final isPointedAt = line.isPointedAt(from, through);
      assert(isPointedAt, 'Line should be pointed at');
    });

    test('Is not pointed at when crossed', () {
      const line = const LinearFunction(1, 1, 3);
      final from = Vector2.zero();
      final through = Vector2.all(3);
      final isPointedAt = line.isPointedAt(from, through);
      assert(!isPointedAt, 'Line should not be pointed at');
    });

    test('Is not pointed at when parallel', () {
      const line = const LinearFunction(1, 1, 3);
      final from = Vector2.zero();
      final through = Vector2(1,-1);
      final isPointedAt = line.isPointedAt(from, through);
      assert(!isPointedAt, 'Line should not be pointed at');
    });

    test('Horizonal line can be pointed at', () {
      const line = const LinearFunction(0, 1, 2);
      final from = Vector2.zero();
      final through = Vector2.all(1);
      final isPointedAt = line.isPointedAt(from, through);
      assert(isPointedAt, 'Line should be pointed at');
    });

    test('Vertical line can be pointed at', () {
      const line = const LinearFunction(1, 0, 2);
      final from = Vector2.zero();
      final through = Vector2.all(1);
      final isPointedAt = line.isPointedAt(from, through);
      assert(isPointedAt, 'Line should be pointed at');
    });
  });

  group('collisionPoints tests', () {
    test('Can catch simple hitbox collision', () {
      final hitboxA = [
        Vector2(2,2),
        Vector2(3,1),
        Vector2(2,0),
        Vector2(1,1),
      ];
      final hitboxB = [
        Vector2(1,2),
        Vector2(2,1),
        Vector2(1,0),
        Vector2(0,1),
      ];
      final intersections = collisionPoints(hitboxA, hitboxB);
      print(intersections);
    });
  });
}
