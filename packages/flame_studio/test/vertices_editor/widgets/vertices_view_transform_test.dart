import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/vertices_editor/widgets/widgets.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(VerticesViewTransform, () {
    const square = ComponentVertices.square;

    test('fit centers vertices that fit without scaling them', () {
      final transform = VerticesViewTransform.fit(square, const Size(400, 300));

      expect(transform.scale, equals(1));
      expect(
        transform.toCanvas(const ComponentVertex(25, 25)),
        equals(const Offset(200, 150)),
      );
    });

    test('fit scales down vertices that do not fit', () {
      final transform = VerticesViewTransform.fit(const [
        ComponentVertex(0, 0),
        ComponentVertex(1000, 0),
        ComponentVertex(0, 100),
      ], const Size(596, 400));

      expect(transform.scale, equals(0.5));
      expect(
        transform.toCanvas(const ComponentVertex(500, 50)),
        equals(const Offset(298, 200)),
      );
    });

    test('toLocal is the inverse of toCanvas, rounded', () {
      const transform = VerticesViewTransform(scale: 2, offset: Offset(10, 20));

      expect(
        transform.toCanvas(const ComponentVertex(5, 5)),
        equals(const Offset(20, 30)),
      );
      expect(
        transform.toLocal(const Offset(20.8, 29.2)),
        equals(const ComponentVertex(5, 5)),
      );
    });

    test('zoomed scales around the center, which stays in place', () {
      const transform = VerticesViewTransform(scale: 2, offset: Offset(10, 20));
      const center = Offset(100, 100);
      final zoomed = transform.zoomed(3, center);

      expect(zoomed.scale, equals(6));
      // The local point under the center doesn't move.
      final local = (center - transform.offset) / transform.scale;
      expect(zoomed.toCanvas(ComponentVertex(local.dx, local.dy)), center);
      expect(transform.zoomed(1, center), equals(transform));
    });

    group('hit testing', () {
      const transform = VerticesViewTransform();

      test('vertexAt finds the closest handle within the hit radius', () {
        expect(transform.vertexAt(square, const Offset(48, 3)), equals(1));
        expect(transform.vertexAt(square, const Offset(25, 25)), isNull);
      });

      test('midpointAt finds the middle of edges', () {
        expect(transform.midpointOf(square, 3), equals(const Offset(0, 25)));
        expect(transform.midpointAt(square, const Offset(2, 24)), equals(3));
        expect(transform.midpointAt(square, Offset.zero), isNull);
      });

      test('edgeNear finds edges near the point', () {
        expect(transform.edgeNear(square, const Offset(40, 52)), equals(2));
        expect(transform.edgeNear(square, const Offset(25, 25)), isNull);
        expect(
          transform.edgeNear(const [
            ComponentVertex(0, 0),
            ComponentVertex(0, 0),
            ComponentVertex(50, 50),
          ], const Offset(-3, -4)),
          isNotNull,
        );
      });
    });
  });
}
