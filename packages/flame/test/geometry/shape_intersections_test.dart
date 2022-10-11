import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:test/test.dart';

void main() {
  group('CircleCircleIntersections', () {
    test('circles not intersecting', () {
      final circleA = CircleHitbox(position: Vector2(10, 10), radius: 5);
      final circleB = CircleHitbox(position: Vector2(21, 10), radius: 5);
      final cc = CircleCircleIntersections();
      expect(
        cc.intersect(circleA, circleB).length,
        0,
        reason: 'There should be no intersections',
      );
    });

    test('circles intersecting', () {
      final circleA = CircleHitbox(position: Vector2(10, 10), radius: 5);
      final circleB = CircleHitbox(position: Vector2(19, 10), radius: 5);
      final cc = CircleCircleIntersections();
      expect(
        cc.intersect(circleA, circleB).length,
        2,
        reason: 'There should be 2 intersections',
      );
    });

    test('circle overlay intersecting', () {
      final circleA = CircleHitbox(position: Vector2(10, 10), radius: 5);
      final circleB = CircleHitbox(position: Vector2(10, 10), radius: 5);
      final cc = CircleCircleIntersections();
      expect(
        cc.intersect(circleA, circleB).length,
        4,
        reason: 'There should be 4 intersections',
      );
    });

    test('small circle inside hollow large circle', () {
      final circleA = CircleHitbox(
        position: Vector2(20, 80),
        radius: 15,
        anchor: Anchor.center,
      );
      final circleB = CircleHitbox(
        position: Vector2(18, 82),
        radius: 5,
        anchor: Anchor.center,
      );
      final cc = CircleCircleIntersections();
      expect(
        cc.intersect(circleA, circleB).length,
        0,
        reason: 'There should be no intersections',
      );
    });

    test('small circle inside solid large circle', () {
      final circleA = CircleHitbox(
        position: Vector2(20, 80),
        radius: 15,
        anchor: Anchor.center,
        isSolid: true,
      );
      final circleB = CircleHitbox(
        position: Vector2(18, 82),
        radius: 5,
        anchor: Anchor.center,
      );
      final cc = CircleCircleIntersections();
      expect(
        cc.intersect(circleA, circleB).length,
        1,
        reason: 'There should be 1 intersection',
      );
    });
  });

  group('PolygonPolygonIntersections', () {
    test('polygons not intersecting', () {
      final polyA = PolygonHitbox([
        Vector2(10, 5),
        Vector2(3, 15),
        Vector2(17, 10),
      ]);
      final polyB = PolygonHitbox([
        Vector2(21, 2),
        Vector2(14, 5),
        Vector2(30, 10),
      ]);
      final pp = PolygonPolygonIntersections();
      expect(
        pp.intersect(polyA, polyB).length,
        0,
        reason: 'There should be no intersections',
      );
    });

    test('polygons intersecting', () {
      final polyA = PolygonHitbox([
        Vector2(10, 5),
        Vector2(3, 15),
        Vector2(17, 10),
      ]);
      final polyB = PolygonHitbox([
        Vector2(21, 2),
        Vector2(10, 9),
        Vector2(30, 10),
      ]);
      final pp = PolygonPolygonIntersections();
      expect(
        pp.intersect(polyA, polyB).length,
        2,
        reason: 'There should be 2 intersections',
      );
    });

    test('polygon overlay intersecting', () {
      final polyA = PolygonHitbox([
        Vector2(10, 5),
        Vector2(3, 15),
        Vector2(17, 10),
      ]);
      final polyB = PolygonHitbox([
        Vector2(10, 5),
        Vector2(3, 15),
        Vector2(17, 10),
      ]);
      final pp = PolygonPolygonIntersections();
      expect(
        pp.intersect(polyA, polyB).length,
        6,
        reason: 'There should be 6 intersections',
      );
    });

    test('small polygon inside hollow large polygon', () {
      final polyA = PolygonHitbox([
        Vector2(10, 5),
        Vector2(3, 15),
        Vector2(17, 10),
      ]);
      final polyB = PolygonHitbox([
        Vector2(20, 4),
        Vector2(1, 2),
        Vector2(2, 18),
        Vector2(18, 19),
      ]);
      final pp = PolygonPolygonIntersections();
      expect(
        pp.intersect(polyA, polyB).length,
        0,
        reason: 'There should be no intersections',
      );
    });

    test('small polygon inside solid large polygon', () {
      final polyA = PolygonHitbox([
        Vector2(10, 5),
        Vector2(3, 15),
        Vector2(17, 10),
      ]);
      final polyB = PolygonHitbox(
        [
          Vector2(20, 4),
          Vector2(1, 2),
          Vector2(2, 18),
          Vector2(18, 19),
        ],
        isSolid: true,
      );
      final pp = PolygonPolygonIntersections();
      expect(
        pp.intersect(polyA, polyB).length,
        1,
        reason: 'There should be 1 intersection',
      );
    });
  });

  group('CirclePolygonIntersections', () {
    test('circle and polygon not intersecting', () {
      final circleA = CircleHitbox(
        position: Vector2(40, 10),
        radius: 5,
        anchor: Anchor.center,
      );
      final polyB = PolygonHitbox([
        Vector2(20, 1),
        Vector2(5, 20),
        Vector2(35, 22),
      ]);
      final cp = CirclePolygonIntersections();
      expect(
        cp.intersect(circleA, polyB).length,
        0,
        reason: 'There should be no intersections',
      );
    });

    test('circle and polygon intersecting', () {
      final circleA = CircleHitbox(
        position: Vector2(37, 24),
        radius: 5,
        anchor: Anchor.center,
      );
      final polyB = PolygonHitbox([
        Vector2(20, 1),
        Vector2(5, 20),
        Vector2(35, 22),
      ]);
      final cp = CirclePolygonIntersections();
      expect(
        cp.intersect(circleA, polyB).length,
        2,
        reason: 'There should be 2 intersections',
      );
    });

    test('small circle inside hollow large polygon', () {
      final circleA = CircleHitbox(
        position: Vector2(19, 11),
        radius: 5,
        anchor: Anchor.center,
      );
      final polyB = PolygonHitbox([
        Vector2(20, 1),
        Vector2(5, 20),
        Vector2(35, 22),
      ]);
      final cp = CirclePolygonIntersections();
      expect(
        cp.intersect(circleA, polyB).length,
        0,
        reason: 'There should be no intersections',
      );
    });

    test('small circle inside solid large polygon', () {
      final circleA = CircleHitbox(
        position: Vector2(19, 11),
        radius: 5,
        anchor: Anchor.center,
      );
      final polyB = PolygonHitbox(
        [
          Vector2(20, 1),
          Vector2(5, 20),
          Vector2(35, 22),
        ],
        isSolid: true,
      );
      final cp = CirclePolygonIntersections();
      expect(
        cp.intersect(circleA, polyB).length,
        1,
        reason: 'There should be 1 intersection',
      );
    });

    test('small polygon inside hollow large circle', () {
      final circleA = CircleHitbox(
        position: Vector2(21, 23),
        radius: 20,
        anchor: Anchor.center,
      );
      final polyB = PolygonHitbox([
        Vector2(20, 8),
        Vector2(10, 30),
        Vector2(32, 28),
      ]);
      final cp = CirclePolygonIntersections();
      expect(
        cp.intersect(circleA, polyB).length,
        0,
        reason: 'There should be no intersections',
      );
    });

    test('small polygon inside solid large circle', () {
      final circleA = CircleHitbox(
        position: Vector2(21, 23),
        radius: 20,
        anchor: Anchor.center,
        isSolid: true,
      );
      final polyB = PolygonHitbox([
        Vector2(20, 8),
        Vector2(10, 30),
        Vector2(32, 28),
      ]);
      final cp = CirclePolygonIntersections();
      expect(
        cp.intersect(circleA, polyB).length,
        1,
        reason: 'There should be 1 intersection',
      );
    });
  });
}
