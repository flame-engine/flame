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
  });
}
