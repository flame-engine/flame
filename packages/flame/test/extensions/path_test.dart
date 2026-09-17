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

void main() {
  group('walkContours', () {
    test('a rectangle gives its corners', () {
      final path = Path()..addRect(const Rect.fromLTWH(0, 0, 100, 50));
      for (final granularity in [1.0, 2.0, 5.0]) {
        expect(
          path.walkContours(granularity).single,
          const [Offset.zero, Offset(100, 0), Offset(100, 50), Offset(0, 50)],
          reason: 'granularity $granularity',
        );
      }
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

    test('small paths are followed at their own scale', () {
      final path = Path()..addOval(const Rect.fromLTWH(0, 0, 1, 1));
      final polygon = path.walkContours(0.01).single;
      expect(polygon.length, greaterThan(12));
      expect(_area(polygon), closeTo(pi / 4, pi / 4 * 0.02));
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
  });
}
