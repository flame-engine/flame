import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Path _square(double left, double top, double size) {
  return Path()..addRect(Rect.fromLTWH(left, top, size, size));
}

/// A hitbox for the union of the [paths], which keeps their positions.
SvgPathsHitbox _hitbox(List<Path> paths, {bool filter = false}) {
  final combined = Path();
  for (final path in paths) {
    combined.addPath(path, Offset.zero);
  }
  final bounds = combined.getBounds();
  return SvgPathsHitbox(
    path: combined,
    filter: filter,
    position: bounds.topLeft.toVector2(),
  );
}

Ray2 _ray(double x, double y, double dx, double dy) {
  return Ray2(origin: Vector2(x, y), direction: Vector2(dx, dy)..normalize());
}

void main() {
  group('SvgPathsHitbox', () {
    // Two overlapping squares: A is [0, 100]², B is [50, 150]².
    final overlapping = [_square(0, 0, 100), _square(50, 50, 100)];

    test('a ray from outside hits the first edge of the union', () {
      final result = _hitbox(overlapping).rayIntersection(_ray(-20, 25, 1, 0));
      expect(result, isNotNull);
      expect(result!.isInsideHitbox, isFalse);
      expect(result.distance, closeTo(20, 1e-3));
      expect(result.intersectionPoint!.x, closeTo(0, 1e-3));
    });

    test('a ray from outside ignores the edges inside of the union', () {
      // Enters through A at x = 0 and passes B's edge at x = 50 inside of A.
      final result = _hitbox(overlapping).rayIntersection(_ray(-20, 75, 1, 0));
      expect(result!.distance, closeTo(20, 1e-3));
    });

    test('a ray from inside leaves the union, not the closest polygon', () {
      // Starts inside of A only, and crosses B's left edge at x = 50 before
      // leaving B at x = 150.
      final result = _hitbox(overlapping).rayIntersection(_ray(25, 75, 1, 0));
      expect(result, isNotNull);
      expect(result!.isInsideHitbox, isTrue);
      expect(result.intersectionPoint!.x, closeTo(150, 1e-3));
    });

    test('a ray from the overlap leaves the union', () {
      final result = _hitbox(overlapping).rayIntersection(_ray(75, 75, 0, 1));
      expect(result!.isInsideHitbox, isTrue);
      expect(result.intersectionPoint!.y, closeTo(150, 1e-3));
    });

    test('a ray starting inside of a nested polygon leaves the outer one', () {
      final nested = [_square(0, 0, 100), _square(40, 40, 20)];
      final result = _hitbox(nested).rayIntersection(_ray(50, 50, 1, 0));
      expect(result!.isInsideHitbox, isTrue);
      expect(result.intersectionPoint!.x, closeTo(100, 1e-3));
    });

    test('the hit normal faces the origin of the ray', () {
      final outside = _hitbox(overlapping).rayIntersection(_ray(-20, 25, 1, 0));
      expect(outside!.normal!.x, closeTo(-1, 1e-6));
      final inside = _hitbox(overlapping).rayIntersection(_ray(25, 75, 1, 0));
      expect(inside!.normal!.x, closeTo(-1, 1e-6));
    });

    test('adjacent polygons with a shared edge form a continuous solid', () {
      final adjacent = [_square(0, 0, 50), _square(50, 0, 50)];
      final inside = _hitbox(adjacent).rayIntersection(_ray(10, 25, 1, 0));
      expect(inside!.isInsideHitbox, isTrue);
      expect(inside.intersectionPoint!.x, closeTo(100, 1e-3));
      final outside = _hitbox(adjacent).rayIntersection(_ray(-20, 25, 1, 0));
      expect(outside!.isInsideHitbox, isFalse);
      expect(outside.intersectionPoint!.x, closeTo(0, 1e-3));
    });

    test('a ray that misses everything has no result', () {
      final hitbox = _hitbox(overlapping);
      expect(hitbox.rayIntersection(_ray(-20, 25, -1, 0)), isNull);
      expect(hitbox.rayIntersection(_ray(-20, 200, 1, 0)), isNull);
    });

    test('a ray that only touches a vertex has no result', () {
      final diamond = Path()
        ..moveTo(10, 0)
        ..lineTo(20, 10)
        ..lineTo(10, 20)
        ..lineTo(0, 10)
        ..close();
      // The square above makes the ray pass within the bounding box.
      final hitbox = _hitbox([diamond, _square(100, -30, 10)]);
      final out = RaycastResult<ShapeHitbox>();
      expect(hitbox.rayIntersection(_ray(-5, 0, 1, 0), out: out), isNull);
      expect(out.isActive, isFalse);
      expect(hitbox.rayIntersection(_ray(-5, 10, 1, 0)), isNotNull);
    });

    test('a ray hits a thin polygon far from the origin', () {
      // The polygon is thinner than the tolerance of the crossings there.
      final thin = Path()..addRect(const Rect.fromLTWH(10000, 0, 0.5, 100));
      final result = _hitbox([thin]).rayIntersection(_ray(9000, 50, 1, 0));
      expect(result, isNotNull);
      expect(result!.isInsideHitbox, isFalse);
      expect(result.intersectionPoint!.x, closeTo(10000, 1e-3));
    });

    test('a ray that misses the bounding box has no result', () {
      final hitbox = _hitbox(overlapping);
      final out = RaycastResult<ShapeHitbox>();
      // Passes above, below and beside the box, and points away from it.
      expect(hitbox.rayIntersection(_ray(-20, -20, 1, 0), out: out), isNull);
      expect(out.isActive, isFalse);
      expect(hitbox.rayIntersection(_ray(75, 200, 1, 0)), isNull);
      expect(hitbox.rayIntersection(_ray(200, 75, 0, 1)), isNull);
      expect(hitbox.rayIntersection(_ray(75, -20, 0, -1)), isNull);
    });

    test('a ray that starts inside the bounding box is still tested', () {
      // (10, 140) is in the bounding box, but outside of both squares.
      final hitbox = _hitbox(overlapping);
      expect(hitbox.rayIntersection(_ray(10, 140, 1, 0)), isNotNull);
      expect(hitbox.rayIntersection(_ray(10, 140, -1, 0)), isNull);
    });

    test('populates and returns the given result', () {
      final out = RaycastResult<ShapeHitbox>();
      final hitbox = _hitbox(overlapping);
      final result = hitbox.rayIntersection(_ray(-20, 25, 1, 0), out: out);
      expect(identical(result, out), isTrue);
      expect(out.hitbox, hitbox);
      expect(hitbox.rayIntersection(_ray(-20, 200, 1, 0), out: out), isNull);
      expect(out.isActive, isFalse);
    });
  });
}
