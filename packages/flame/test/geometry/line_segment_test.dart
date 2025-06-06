import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:test/test.dart';

void main() {
  group('LineSegment', () {
    test('midpoint', () {
      final lineSegment1 = LineSegment(Vector2.zero(), Vector2.all(2));
      expect(lineSegment1.midpoint, Vector2.all(1));

      final lineSegment2 = LineSegment(Vector2.all(0), Vector2(0, 2));
      expect(lineSegment2.midpoint, Vector2(0, 1));
    });

    test('(to, from) and (direction, length) are equivalent', () {
      final lineSegment1 = LineSegment(Vector2(1, 1), Vector2(2, 1));
      expect(lineSegment1.from, Vector2(1, 1));
      expect(lineSegment1.to, Vector2(2, 1));

      expect(lineSegment1.length, 1);
      expect(lineSegment1.direction, Vector2(1, 0));

      final lineSegment2 = LineSegment.withLength(
        start: Vector2(1, 1),
        direction: Vector2(1, 0),
        length: 1,
      );
      expect(lineSegment2.from, Vector2(1, 1));
      expect(lineSegment2.to, Vector2(2, 1));

      expect(lineSegment2.length, 1);
      expect(lineSegment2.direction, Vector2(1, 0));
    });

    test('translate line segment', () {
      final line = LineSegment(Vector2.all(1), Vector2.all(2));

      final lineUp = line.translate(Vector2(0, -1));
      expect(lineUp.from, Vector2(1, 0));
      expect(lineUp.to, Vector2(2, 1));

      final lineDown = line.translate(Vector2(0, 1));
      expect(lineDown.from, Vector2(1, 2));
      expect(lineDown.to, Vector2(2, 3));

      final lineLeft = line.translate(Vector2(-1, 0));
      expect(lineLeft.from, Vector2(0, 1));
      expect(lineLeft.to, Vector2(1, 2));

      final lineRight = line.translate(Vector2(1, 0));
      expect(lineRight.from, Vector2(2, 1));
      expect(lineRight.to, Vector2(3, 2));

      final lineDiagonal = line.translate(Vector2(1, -1));
      expect(lineDiagonal.from, Vector2(2, 0));
      expect(lineDiagonal.to, Vector2(3, 1));
    });

    test('inflate and deflate', () {
      final line = LineSegment(Vector2(1, 2), Vector2(3, 2));

      final inflatedLine = line.inflate(1);
      expect(inflatedLine.from, Vector2(0, 2));
      expect(inflatedLine.to, Vector2(4, 2));

      final deflatedLine = line.deflate(0.5);
      expect(deflatedLine.from, Vector2(1.5, 2));
      expect(deflatedLine.to, Vector2(2.5, 2));
    });

    test('spread', () {
      final line = LineSegment(Vector2(0, 0), Vector2(10, 0));

      final points1 = line.spread(4);
      expect(points1.length, 4);
      expect(points1[0], Vector2(2, 0));
      expect(points1[1], Vector2(4, 0));
      expect(points1[2], Vector2(6, 0));
      expect(points1[3], Vector2(8, 0));

      final points2 = line.spread(0);
      expect(points2.length, 0);

      // expect an exception with message for negative amount
      expect(
        () => line.spread(-1),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Amount must be non-negative',
          ),
        ),
      );
    });

    test('Slightly angled line segments should intersect', () {
      // This tests that the epsilon is sufficiently large, see #3587
      final lineA = LineSegment(Vector2(-27.5, 2.5), Vector2(-22.5, 2.5));
      final lineB = LineSegment(Vector2(-25, -25), Vector2(-25 + 1 / 18, 25));
      expect(lineA.intersections(lineB), isNotEmpty);
    });
  });
}
