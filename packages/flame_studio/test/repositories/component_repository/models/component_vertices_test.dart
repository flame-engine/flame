import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ComponentVertices, () {
    test('defaults to a triangle', () {
      expect(
        const ComponentVertices().vertices,
        equals(ComponentVertices.triangle),
      );
    });

    test('round-trips through JSON', () {
      const vertices = ComponentVertices([
        ComponentVertex(1, 2),
        ComponentVertex(3.5, 4),
        ComponentVertex(-5, 6),
      ]);

      expect(ComponentVertices.fromJson(vertices.toJson()), equals(vertices));
    });

    test('fromJson skips invalid vertices', () {
      expect(
        ComponentVertices.fromJson(const {
          'vertices': [
            {'x': 0, 'y': 0},
            {'x': 'a', 'y': 0},
            'invalid',
            {'x': 1, 'y': 0},
            {'x': 1, 'y': 1},
          ],
        }),
        equals(
          const ComponentVertices([
            ComponentVertex(0, 0),
            ComponentVertex(1, 0),
            ComponentVertex(1, 1),
          ]),
        ),
      );
    });

    test('fromJson falls back to the default with fewer than 3 vertices', () {
      expect(
        ComponentVertices.fromJson(const {
          'vertices': [
            {'x': 0, 'y': 0},
            {'x': 1, 'y': 0},
          ],
        }),
        equals(const ComponentVertices()),
      );
      expect(
        ComponentVertices.fromJson(null),
        equals(const ComponentVertices()),
      );
      expect(
        ComponentVertices.fromJson(const {'vertices': 'invalid'}),
        equals(const ComponentVertices()),
      );
    });

    test('bounds is the size of the bounding box', () {
      const vertices = ComponentVertices([
        ComponentVertex(-10, 5),
        ComponentVertex(20, 0),
        ComponentVertex(0, 40),
      ]);

      expect(vertices.bounds, equals((width: 30.0, height: 40.0)));
    });

    test('normalized moves the bounding box to the origin', () {
      const vertices = ComponentVertices([
        ComponentVertex(-10, 5),
        ComponentVertex(20, 10),
        ComponentVertex(0, 40),
      ]);

      expect(
        vertices.normalized(),
        equals(
          const ComponentVertices([
            ComponentVertex(0, 0),
            ComponentVertex(30, 5),
            ComponentVertex(10, 35),
          ]),
        ),
      );
      expect(
        const ComponentVertices().normalized(),
        same(const ComponentVertices()),
      );
    });
  });

  group(PolygonShape, () {
    test('has the vertices of its shape', () {
      expect(
        PolygonShape.triangle.vertices,
        equals(ComponentVertices.triangle),
      );
      expect(PolygonShape.square.vertices, hasLength(4));
    });
  });
}
