import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

void main() {
  group('PolygonHitbox.regular', () {
    test('creates the expected number of vertices', () {
      final hitbox = PolygonHitbox.regular(sides: 7, radius: 10);

      expect(hitbox.vertices, hasLength(7));
    });

    test('places all vertices at the given radius from the center', () {
      const radius = 12.5;
      final hitbox = PolygonHitbox.regular(sides: 8, radius: radius);

      for (final vertex in hitbox.vertices) {
        expect(vertex.length, closeTo(radius, 1e-10));
      }
    });

    test('uses center anchor by default', () {
      final hitbox = PolygonHitbox.regular(sides: 5, radius: 10);

      expect(hitbox.anchor, Anchor.center);
    });

    test('supports custom position and anchor', () {
      final hitbox = PolygonHitbox.regular(
        sides: 6,
        radius: 3,
        position: Vector2(10, 20),
        anchor: Anchor.topLeft,
      );

      expect(hitbox.position.x, closeTo(10, 1e-10));
      expect(hitbox.position.y, closeTo(20, 1e-10));
      expect(hitbox.anchor, Anchor.topLeft);
    });

    test('throws assertion error when sides are less than 3', () {
      expect(
        () => PolygonHitbox.regular(sides: 2, radius: 5),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
