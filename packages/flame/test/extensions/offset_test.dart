import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('OffsetExtension', () {
    testRandom('toVector2 has x to offset.dx and y to offset.dy', (Random r) {
      final offset = Offset(r.nextDouble(), r.nextDouble());
      final vector2 = offset.toVector2();

      expect(
        vector2.x,
        closeTo(offset.dx, 1e-6),
        reason: 'x dx does not match',
      );
      expect(
        vector2.y,
        closeTo(offset.dy, 1e-6),
        reason: 'y dy does not match',
      );
    });

    testRandom('toSize has width to offset.dx and height to offset.dy', (
      Random r,
    ) {
      final offset = Offset(r.nextDouble(), r.nextDouble());
      final size = offset.toSize();

      expect(size.width, offset.dx, reason: 'width dx does not match');
      expect(size.height, offset.dy, reason: 'height dy does not match');
    });

    testRandom('toSize has x to offset.dx and y to offset.dy', (Random r) {
      final offset = Offset(r.nextDouble(), r.nextDouble());
      final point = offset.toPoint();

      expect(point.x, offset.dx, reason: 'x dx does not match');
      expect(point.y, offset.dy, reason: 'y dy does not match');
    });

    testRandom(
      'toRect has left: 0, top: 0, width: offset.dx, height: offset.dy',
      (Random r) {
        final offset = Offset(r.nextDouble(), r.nextDouble());
        final rect = offset.toRect();

        expect(rect.left, 0, reason: 'left should be 0 as init');
        expect(rect.top, 0, reason: 'top should be 0 as init');
        expect(rect.width, offset.dx, reason: 'width dx does not match');
        expect(rect.height, offset.dy, reason: 'height dy does not match');
      },
    );

    group('distanceToSegmentSquared', () {
      const from = Offset(1, 1);
      const to = Offset(5, 1);

      test('is the distance to the segment for a point next to it', () {
        expect(const Offset(3, 4).distanceToSegmentSquared(from, to), 9);
      });

      test('is the distance to the closest end for a point beyond it', () {
        expect(const Offset(-2, 5).distanceToSegmentSquared(from, to), 25);
        expect(const Offset(8, -3).distanceToSegmentSquared(from, to), 25);
      });

      test('is zero for a point on the segment', () {
        expect(const Offset(2, 1).distanceToSegmentSquared(from, to), 0);
        expect(from.distanceToSegmentSquared(from, to), 0);
        expect(to.distanceToSegmentSquared(from, to), 0);
      });

      test('is the distance to the point of a segment without a length', () {
        expect(const Offset(4, 5).distanceToSegmentSquared(from, from), 25);
      });

      test('does not depend on the direction of the segment', () {
        const point = Offset(2.5, -3.25);
        expect(
          point.distanceToSegmentSquared(from, to),
          point.distanceToSegmentSquared(to, from),
        );
      });
    });
  });
}
