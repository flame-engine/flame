import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('Aabb2Extension', () {
    // aabb2 is an axis aligned bounding box between a min and a max
    // see https://api.flutter.dev/flutter/vector_math_64/Aabb2-class.html
    // The extension is used to convert this bounding box to a rect.
    test('Default aabb constructor', () {
      final aab2 = Aabb2();
      // With this constructor, min and max are set to the origin (0,0)
      // So the corresponding rect should be (0,0,0,0)
      final aab2Rect = aab2.toRect();
      _checkRectValues(
        aab2Rect,
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
      );
    });

    testRandom('centerAndHalfExtents constructor', (Random r) {
      // This constructor is useful in circles (see lib/src/experimental/geometry/shapes/circle.dart)
      final center = Vector2(r.nextDouble(), r.nextDouble());
      final halfExtends = Vector2(r.nextDouble(), r.nextDouble());

      final aab2 = Aabb2.centerAndHalfExtents(center, halfExtends);
      final aab2Rect = aab2.toRect();

      _checkRectValues(
        aab2Rect,
        left: aab2.min.x,
        top: aab2.min.y,
        right: aab2.max.x,
        bottom: aab2.max.y,
      );
    });

    testRandom('aabb minMax constructor', (Random r) {
      final min = Vector2(r.nextDouble(), r.nextDouble());
      final max = Vector2(r.nextDouble(), r.nextDouble());

      final aab2 = Aabb2.minMax(min, max);
      final aab2Rect = aab2.toRect();

      _checkRectValues(
        aab2Rect,
        left: min.x,
        top: min.y,
        right: max.x,
        bottom: max.y,
      );
    });

    group('intersectionWithAabb2', () {
      test('is the area that both boxes cover', () {
        final aabb2 = Aabb2.minMax(Vector2(0, 0), Vector2(10, 10));
        final other = Aabb2.minMax(Vector2(4, -3), Vector2(15, 6));

        expect(
          aabb2.intersectionWithAabb2(other),
          const Rect.fromLTRB(4, 0, 10, 6),
        );
        expect(
          other.intersectionWithAabb2(aabb2),
          const Rect.fromLTRB(4, 0, 10, 6),
        );
      });

      test('is the inner box when it is fully contained', () {
        final aabb2 = Aabb2.minMax(Vector2(0, 0), Vector2(10, 10));
        final inner = Aabb2.minMax(Vector2(2, 3), Vector2(4, 5));

        expect(aabb2.intersectionWithAabb2(inner), inner.toRect());
      });

      test('has a negative extent when the boxes do not overlap', () {
        final aabb2 = Aabb2.minMax(Vector2(0, 0), Vector2(1, 1));
        final other = Aabb2.minMax(Vector2(3, 0), Vector2(4, 1));

        final intersection = aabb2.intersectionWithAabb2(other);
        expect(intersection.width, isNegative);
        expect(intersection.isEmpty, isTrue);
      });
    });

    group('fromVertices', () {
      test('spans the extremes of the vertices', () {
        final aabb2 = Aabb2Extension.fromVertices([
          Vector2(2, -7),
          Vector2(-4, 1),
          Vector2(9, 3),
          Vector2(0, 12),
          Vector2(1, 2),
        ]);

        expect(aabb2.min, Vector2(-4, -7));
        expect(aabb2.max, Vector2(9, 12));
      });

      test('does not include the origin for vertices away from it', () {
        final aabb2 = Aabb2Extension.fromVertices([
          Vector2(10, 20),
          Vector2(30, 25),
          Vector2(15, 40),
        ]);

        expect(aabb2.min, Vector2(10, 20));
        expect(aabb2.max, Vector2(30, 40));
      });

      test('is a point for a single vertex', () {
        final vertex = Vector2(3, -5);
        final aabb2 = Aabb2Extension.fromVertices([vertex]);

        expect(aabb2.min, Vector2(3, -5));
        expect(aabb2.max, Vector2(3, -5));
        expect(aabb2.min, isNot(same(vertex)));
        expect(aabb2.max, isNot(same(vertex)));
      });

      test('is empty at the origin without vertices', () {
        final aabb2 = Aabb2Extension.fromVertices([]);

        expect(aabb2.min, Vector2.zero());
        expect(aabb2.max, Vector2.zero());
      });

      test('leaves the vertices untouched', () {
        final vertices = [Vector2(5, 5), Vector2(-1, 8), Vector2(7, -2)];
        Aabb2Extension.fromVertices(vertices);

        expect(vertices, [Vector2(5, 5), Vector2(-1, 8), Vector2(7, -2)]);
      });
    });
  });
}

void _checkRectValues(
  Rect rect, {
  required double left,
  required double top,
  required double right,
  required double bottom,
}) {
  expect(rect.left, left, reason: 'left does not match');
  expect(rect.top, top, reason: 'top does not match');
  expect(rect.right, right, reason: 'right does not match');
  expect(rect.bottom, bottom, reason: 'bottom does not match');
}
