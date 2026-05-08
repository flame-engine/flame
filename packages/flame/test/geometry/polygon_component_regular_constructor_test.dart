import 'package:flame/components.dart';
import 'package:test/test.dart';

void main() {
  group('PolygonComponent.regular', () {
    test('creates the expected number of vertices', () {
      final component = PolygonComponent.regular(sides: 7, radius: 10);

      expect(component.vertices, hasLength(7));
    });

    test('places all vertices at the given radius from local center', () {
      const radius = 12.5;
      final component = PolygonComponent.regular(sides: 8, radius: radius);
      final center = Vector2.all(radius);

      for (final vertex in component.vertices) {
        expect(vertex.distanceTo(center), closeTo(radius, 1e-8));
      }
    });

    test('uses top left anchor by default', () {
      final component = PolygonComponent.regular(sides: 5, radius: 10);

      expect(component.anchor, Anchor.topLeft);
    });

    test('supports custom position and anchor', () {
      final component = PolygonComponent.regular(
        sides: 6,
        radius: 3,
        position: Vector2(10, 20),
        anchor: Anchor.topLeft,
      );

      expect(component.position.x, closeTo(10, 1e-10));
      expect(component.position.y, closeTo(20, 1e-10));
      expect(component.anchor, Anchor.topLeft);
    });

    test('throws assertion error when sides are less than 3', () {
      expect(
        () => PolygonComponent.regular(sides: 2, radius: 5),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
