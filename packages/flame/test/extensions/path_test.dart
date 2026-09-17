import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:test/test.dart';

double _area(List<Offset> polygon) {
  var area = 0.0;
  for (var i = 0; i < polygon.length; i++) {
    final from = polygon[i];
    final to = polygon[(i + 1) % polygon.length];
    area += from.dx * to.dy - to.dx * from.dy;
  }
  return area.abs() / 2;
}

double _shortestEdge(List<Offset> polygon) {
  var shortest = double.infinity;
  for (var i = 0; i < polygon.length; i++) {
    final edge = polygon[(i + 1) % polygon.length] - polygon[i];
    shortest = min(shortest, edge.distance);
  }
  return shortest;
}

Rect _bounds(List<Offset> points) {
  var bounds = Rect.fromPoints(points.first, points.first);
  for (final point in points) {
    bounds = bounds.expandToInclude(Rect.fromPoints(point, point));
  }
  return bounds;
}

void _expectRect(Rect actual, Rect expected, double precision) {
  expect(actual.left, closeTo(expected.left, precision));
  expect(actual.top, closeTo(expected.top, precision));
  expect(actual.right, closeTo(expected.right, precision));
  expect(actual.bottom, closeTo(expected.bottom, precision));
}

void main() {
  group('walkContours', () {
    test('a rectangle gives its corners at any granularity', () {
      final path = Path()..addRect(const Rect.fromLTWH(0, 0, 100, 50));
      for (final granularity in [0.1, 0.3, 0.7, 1.0, 2.0, 7.0]) {
        expect(
          path.walkContours(granularity).single,
          const [Offset.zero, Offset(100, 0), Offset(100, 50), Offset(0, 50)],
          reason: 'granularity $granularity',
        );
      }
    });

    test('corners that are not on the sampling steps are kept', () {
      const corners = [Offset(10.3, 0), Offset(57.7, 33.1), Offset(3.9, 71.2)];
      final path = Path()..addPolygon(corners, true);
      for (final granularity in [1.0, 2.0]) {
        final polygon = path.walkContours(granularity).single;
        expect(polygon, hasLength(3));
        for (var i = 0; i < 3; i++) {
          expect(polygon[i].dx, closeTo(corners[i].dx, 1e-4));
          expect(polygon[i].dy, closeTo(corners[i].dy, 1e-4));
        }
      }
    });

    test('a staircase is not mistaken for a single corner', () {
      final path = Path()
        ..addPolygon(const [
          Offset.zero,
          Offset(20, 0),
          Offset(20, 5),
          Offset(30, 5),
          Offset(30, 40),
          Offset(0, 40),
        ], true);
      expect(path.walkContours(8).single, hasLength(6));
    });

    test('a closed contour does not end next to where it starts', () {
      final paths = [
        Path()..addOval(const Rect.fromLTWH(0, 0, 100, 60)),
        Path()..addRect(const Rect.fromLTWH(0, 0, 100, 50)),
        Path()..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 0, 64, 64),
            const Radius.circular(10),
          ),
        ),
      ];
      for (final path in paths) {
        for (final granularity in [0.1, 1.0, 2.0]) {
          final polygon = path.walkContours(granularity).single;
          expect(_shortestEdge(polygon), greaterThan(granularity / 2));
        }
      }
    });

    test('the bounds of the path are kept', () {
      final paths = [
        Path()..addOval(const Rect.fromLTWH(10, 20, 100, 60)),
        Path()..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 0, 64, 64),
            const Radius.circular(10),
          ),
        ),
        Path()..addPolygon(const [
          Offset(10.3, 0),
          Offset(57.7, 33.1),
          Offset(3.9, 71.2),
        ], true),
        Path()
          ..moveTo(0, 0)
          ..cubicTo(40, -30, 80, 30, 120, 0)
          ..cubicTo(90, 40, 30, 50, 0, 0)
          ..close(),
      ];
      for (final path in paths) {
        // The bounds of a path include the control points of its curves.
        final metric = path.computeMetrics().single;
        final expected = _bounds([
          for (var offset = 0.0; offset < metric.length; offset += 0.001)
            metric.getTangentForOffset(offset)!.position,
        ]);
        for (final granularity in [1.0, 2.0, 5.0]) {
          final polygon = path.walkContours(granularity).single;
          _expectRect(_bounds(polygon), expected, 0.02);
        }
      }
    });

    test('small paths are followed at their own scale', () {
      final path = Path()..addOval(const Rect.fromLTWH(0, 0, 1, 1));
      final polygon = path.walkContours(0.01).single;
      expect(polygon.length, greaterThan(12));
      expect(_area(polygon), closeTo(pi / 4, pi / 4 * 0.02));
    });

    test('the polygon stays within the tolerance of the path', () {
      const radius = 50.0;
      final path = Path()
        ..addOval(Rect.fromCircle(center: Offset.zero, radius: radius));
      for (final (granularity, tolerance) in [(1.0, null), (1.0, 2.0)]) {
        final polygon = path.walkContours(granularity, tolerance).single;
        final allowed = tolerance ?? granularity / 2;
        for (var i = 0; i < polygon.length; i++) {
          final from = polygon[i];
          final to = polygon[(i + 1) % polygon.length];
          expect(from.distance, closeTo(radius, allowed / 6));
          final sagitta = radius - ((from + to) / 2).distance;
          expect(sagitta, lessThanOrEqualTo(allowed * 1.2));
        }
      }
    });

    test('a larger tolerance needs fewer vertices', () {
      final path = Path()..addOval(const Rect.fromLTWH(0, 0, 100, 60));
      final unsimplified = path.walkContours(1, 0).single.length;
      final fine = path.walkContours(1, 0.1).single.length;
      final normal = path.walkContours().single.length;
      final coarse = path.walkContours(1, 3).single.length;
      expect(unsimplified, greaterThan(fine));
      expect(fine, greaterThan(normal));
      expect(normal, greaterThan(coarse));
      expect(coarse, greaterThanOrEqualTo(4));
    });

    test('an open contour keeps both of its ends', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(10, 0)
        ..lineTo(10, 10);
      expect(
        path.walkContours().single,
        const [Offset.zero, Offset(10, 0), Offset(10, 10)],
      );
    });

    test('every contour is walked', () {
      final path = Path()
        ..addRect(const Rect.fromLTWH(0, 0, 10, 10))
        ..addRect(const Rect.fromLTWH(20, 20, 5, 5));
      final contours = path.walkContours();
      expect(contours, hasLength(2));
      expect(contours[1].first, const Offset(20, 20));
      expect(Path().walkContours(), isEmpty);
    });

    test('an invalid granularity is rejected', () {
      final path = Path()..addRect(const Rect.fromLTWH(0, 0, 10, 10));
      for (final granularity in [0.0, -5.0, double.nan, double.infinity]) {
        expect(
          () => path.walkContours(granularity),
          throwsA(isA<AssertionError>()),
        );
      }
      expect(
        () => path.walkContours(1, -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('a tiny granularity does not exhaust the memory', () {
      final path = Path()..addOval(const Rect.fromLTWH(0, 0, 300, 300));
      final polygon = path.walkContours(1e-7, 0.5).single;
      expect(polygon.length, lessThan(200));
    });
  });

  group('walkContourAt', () {
    test('walks only the requested contour', () {
      final path = Path()
        ..addRect(const Rect.fromLTWH(0, 0, 10, 10))
        ..addOval(const Rect.fromLTWH(20, 20, 50, 30));
      final contours = path.walkContours();
      expect(path.walkContourAt(0), contours[0]);
      expect(path.walkContourAt(1), contours[1]);
      expect(path.walkContourAt(1, 2, 0.3), path.walkContours(2, 0.3)[1]);
    });

    test('rejects a contour that does not exist', () {
      final path = Path()..addRect(const Rect.fromLTWH(0, 0, 10, 10));
      expect(() => path.walkContourAt(1), throwsRangeError);
      expect(() => path.walkContourAt(-1), throwsRangeError);
    });
  });

  group('contours', () {
    test('can be read more than once', () {
      final path = Path()
        ..addRect(const Rect.fromLTWH(0, 0, 100, 50))
        ..addRect(const Rect.fromLTWH(200, 0, 10, 10));
      final contours = path.contours;
      expect(contours.contoursLength, 340);
      expect(contours, hasLength(2));
      expect(contours.contoursLength, 340);
      expect(contours.first.length, 300);
    });
  });

  group('resizeTo', () {
    test('keeps the top left corner of the bounds in place', () {
      final path = Path()..addRect(const Rect.fromLTWH(50, 60, 100, 50));
      expect(
        path.resizeTo(const Size(10, 20)).getBounds(),
        const Rect.fromLTWH(50, 60, 10, 20),
      );
    });

    test('fits within the size when the ratio is kept', () {
      final path = Path()..addRect(const Rect.fromLTWH(50, 60, 100, 50));
      expect(
        path.resizeTo(const Size(10, 20), keepRatio: true).getBounds(),
        const Rect.fromLTWH(50, 60, 10, 5),
      );
      expect(
        path.resizeTo(const Size(400, 100), keepRatio: true).getBounds(),
        const Rect.fromLTWH(50, 60, 200, 100),
      );
    });

    test('does not scale a path in a direction that it has no size in', () {
      final line = Path()
        ..moveTo(5, 7)
        ..lineTo(15, 7);
      expect(
        line.resizeTo(const Size(40, 30)).getBounds(),
        const Rect.fromLTWH(5, 7, 40, 0),
      );
      expect(
        line.resizeTo(const Size(40, 30), keepRatio: true).getBounds(),
        const Rect.fromLTWH(5, 7, 40, 0),
      );
      expect(Path().resizeTo(const Size(40, 30)).getBounds(), Rect.zero);
    });

    test('rejects an empty size', () {
      final path = Path()..addRect(const Rect.fromLTWH(0, 0, 10, 10));
      expect(
        () => path.resizeTo(Size.zero),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
