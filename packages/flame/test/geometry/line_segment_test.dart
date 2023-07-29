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
  });
}
