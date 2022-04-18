import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Polygon', () {
    test('simple triangle', () {
      final polygon = Polygon(
        [Vector2.zero(), Vector2(0, 60), Vector2(80, 60)],
      );
      expect(polygon.n, 3);
      expect(polygon.vertices.length, 3);
      expect(polygon.vertices[0], Vector2(0, 0));
      expect(polygon.vertices[1], Vector2(0, 60));
      expect(polygon.vertices[2], Vector2(80, 60));
      expect(polygon.edges.length, 3);
      expect(polygon.edges[0], Vector2(-80, -60));
      expect(polygon.edges[1], Vector2(0, 60));
      expect(polygon.edges[2], Vector2(80, 0));
      expect(polygon.perimeter, 100 + 60 + 80);
      expect(polygon.isConvex, true);
      expect(polygon.isClosed, true);
      expect(
        polygon.aabb,
        closeToAabb(Aabb2.minMax(Vector2.zero(), Vector2(80, 60))),
      );
      expect(polygon.center, closeToVector(80 / 3, 60 * 2 / 3, epsilon: 1e-14));
      expect('$polygon', 'Polygon([[0.0,0.0], [0.0,60.0], [80.0,60.0]])');
    });

    test('triangle with edges in a wrong order', () {
      final polygon1 = Polygon(
        [Vector2(0, 60), Vector2.zero(), Vector2(80, 60)],
      );
      final polygon2 = Polygon(
        [Vector2(80, 60), Vector2.zero(), Vector2(0, 60)],
      );
      expect(polygon1.vertices, polygon2.vertices);
      expect(polygon1.edges, polygon2.edges);
      expect(polygon1.isConvex, true);
      expect(polygon2.isConvex, true);
    });

    test('asPath', () {
      final polygon = Polygon(
        [Vector2.zero(), Vector2(0, 60), Vector2(80, 60)],
      );
      final path = polygon.asPath();
      final metrics = path.computeMetrics().toList();
      expect(metrics.length, 1);
      expect(metrics[0].isClosed, true);
      expect(metrics[0].length, 60 + 80 + 100);
    });

    test('containsPoint', () {
      final polygon = Polygon(
        [Vector2.zero(), Vector2(0, 60), Vector2(80, 60)],
      );
      expect(polygon.containsPoint(Vector2(0, 0)), true);
      expect(polygon.containsPoint(Vector2(1, 0)), false);
      expect(polygon.containsPoint(Vector2(0, 10)), true);
      expect(polygon.containsPoint(Vector2(0, 60)), true);
      expect(polygon.containsPoint(Vector2(20, 30)), true);
      expect(polygon.containsPoint(Vector2(40, 30)), true);
      expect(polygon.containsPoint(Vector2(40, 29)), false);
      expect(polygon.containsPoint(Vector2(41, 30)), false);
      expect(polygon.containsPoint(Vector2(41, 31)), true);
      expect(polygon.containsPoint(Vector2(80, 60)), true);
      expect(polygon.containsPoint(Vector2(70, 55)), true);
      expect(polygon.containsPoint(Vector2(80, 61)), false);
    });

    test('move', () {
      final polygon = Polygon(
        [Vector2.zero(), Vector2(0, 60), Vector2(80, 60)],
      );
      // Force computing (and caching) the aabb and the center
      expect(polygon.aabb.min, Vector2.zero());
      expect(polygon.center, closeToVector(80 / 3, 40, epsilon: 1e-14));

      polygon.move(Vector2(5, -10));
      expect(
        polygon.vertices,
        [Vector2(5, -10), Vector2(5, 50), Vector2(85, 50)],
      );
      expect(
        polygon.edges,
        [Vector2(-80, -60), Vector2(0, 60), Vector2(80, 0)],
      );
      expect(
        polygon.aabb,
        closeToAabb(Aabb2.minMax(Vector2(5, -10), Vector2(85, 50))),
      );
      expect(polygon.center, closeToVector(95 / 3, 30, epsilon: 1e-14));
    });
  });
}
