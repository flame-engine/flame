import 'dart:ui' show PaintingStyle;

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

    test('a ray does not skip a gap between polygons far from the origin', () {
      for (final x in [0.0, 10000.0]) {
        final separated = [_square(x, 0, 10), _square(x + 10.5, 0, 10)];
        final hitbox = _hitbox(separated);
        // From the middle of each square towards the other one.
        for (final ray in [_ray(x + 5, 5, 1, 0), _ray(x + 15.5, 5, -1, 0)]) {
          final result = hitbox.rayIntersection(ray);
          expect(result!.isInsideHitbox, isTrue, reason: '$x');
          expect(result.distance, closeTo(5, 1e-3), reason: '$x');
        }
      }
    });

    test('adjacent polygons far from the origin form a continuous solid', () {
      final adjacent = [_square(10000, 0, 50), _square(10050, 0, 50)];
      final result = _hitbox(adjacent).rayIntersection(_ray(10010, 25, 1, 0));
      expect(result!.isInsideHitbox, isTrue);
      expect(result.intersectionPoint!.x, closeTo(10100, 1e-3));
    });

    test('a shared edge stays continuous when the hitbox is transformed', () {
      final hitbox = _hitbox([_square(0, 0, 50), _square(50, 0, 50)])
        ..position.setValues(12345.678, -9876.5)
        ..angle = 0.7
        ..scale.setValues(3.3, 3.3);
      // Along the x axis of the hitbox, from inside of the first square.
      final origin = hitbox.absolutePositionOf(Vector2(10, 25));
      final direction = hitbox.absolutePositionOf(Vector2(11, 25)) - origin;
      final result = hitbox.rayIntersection(
        Ray2(origin: origin, direction: direction..normalize()),
      );
      expect(result!.isInsideHitbox, isTrue);
      expect(result.distance, closeTo(90 * 3.3, 1e-3));
    });

    test('a ray does not skip a small gap far from the origin', () {
      // The gap and the thin polygon after it are still much larger than the
      // rounding of the paths there.
      final paths = [
        _square(10000, 0, 10),
        Path()..addRect(const Rect.fromLTWH(10010.1, 0, 0.1, 10)),
      ];
      final result = _hitbox(paths).rayIntersection(_ray(10005, 5, 1, 0));
      expect(result!.isInsideHitbox, isTrue);
      expect(result.distance, closeTo(5, 1e-3));
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

    group('fromSvg', () {
      // The paths do not start at the origin, and their bounds are 70x40.
      final svg = SvgPaths(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"> '
        '<path d="M20 10L60 10L60 30Z" fill="#ff0000"/> '
        '<path d="M70 40L90 40L90 50Z" fill="#00ff00"/> </svg>',
      );

      test('fits the bounds of the SVG within the size', () {
        final hitbox = SvgPathsHitbox.fromSvg(svg, Vector2(140, 200));
        // Scaled by 2, and centered vertically.
        expect(hitbox.scale, Vector2.all(2));
        expect(hitbox.position, Vector2(0, 60));
        expect(SvgPathsHitbox.fromSvg(svg, null).scale, Vector2.all(1));
      });

      test('fits the given area within the size', () {
        final hitbox = SvgPathsHitbox.fromSvg(
          svg,
          Vector2.all(50),
          area: const Rect.fromLTWH(0, 0, 100, 100),
        );
        expect(hitbox.scale, Vector2.all(0.5));
        expect(hitbox.position, Vector2(10, 5));
      });

      test('is placed again for another size', () {
        final hitbox = SvgPathsHitbox.fromSvg(svg, null)
          ..place(Vector2(140, 200));
        final expected = SvgPathsHitbox.fromSvg(svg, Vector2(140, 200));
        expect(hitbox.position, expected.position);
        expect(hitbox.scale, expected.scale);
      });

      test('can be rendered', () {
        final hitbox = SvgPathsHitbox.fromSvg(svg, null, renderHitboxes: true);
        expect(hitbox.renderShape, isTrue);
        expect(hitbox.paint.style, PaintingStyle.stroke);
      });

      test('keeps shared edges continuous across group transforms', () {
        // Both paths share the edge at x = 100.3, reached through different
        // transforms, so their vertices there may differ by rounding.
        final adjacent = SvgPaths(
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 100"> '
          '<g transform="translate(0.3 0)"> '
          '<path d="M0 0L100 0L100 50L0 50Z" fill="#ff0000"/></g> '
          '<g transform="scale(0.1 1)"> '
          '<path d="M1003 0L2003 0L2003 50L1003 50Z" fill="#00ff00"/></g> '
          '</svg>',
        );
        // Scaled by 100, so that the coordinates are large.
        final hitbox = SvgPathsHitbox.fromSvg(adjacent, Vector2(20000, 5000));
        expect(hitbox.scale, Vector2.all(100));
        final result = hitbox.rayIntersection(_ray(5000, 2500, 1, 0));
        expect(result!.isInsideHitbox, isTrue);
        expect(result.intersectionPoint!.x, closeTo(20000, 1e-2));
      });

      test('asserts when placing a hitbox that is not from an SVG', () {
        expect(
          () => _hitbox(overlapping).place(Vector2.all(10)),
          throwsAssertionError,
        );
      });
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
