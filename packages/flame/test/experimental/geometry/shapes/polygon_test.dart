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

    test('support', () {
      final polygon = Polygon([
        Vector2(10, 0),
        Vector2(0, 30),
        Vector2(30, 70),
        Vector2(80, 40),
      ]);
      expect(polygon.isConvex, true);

      expect(polygon.support(Vector2(1, 0)), Vector2(80, 40));
      expect(polygon.support(Vector2(-1, 0)), Vector2(0, 30));
      expect(polygon.support(Vector2(0, 1)), Vector2(30, 70));
      expect(polygon.support(Vector2(0, -1)), Vector2(10, 0));
      expect(polygon.support(Vector2(-1, -1)), Vector2(10, 0));
      expect(polygon.support(Vector2(1, 1)), Vector2(80, 40));
    });

    test('weird-shape polygon', () {
      final polygon = Polygon([
        Vector2(20, 40),
        Vector2(50, 30),
        Vector2(70, 60),
        Vector2(50, 40),
        Vector2(40, 60),
        Vector2(90, 80),
        Vector2(100, 20),
        Vector2(90, 50),
        Vector2(60, 10),
        Vector2(40, 25),
      ]);
      expect(polygon.n, 10);
      expect(polygon.isConvex, false);
      expect(polygon.vertices[0], Vector2(20, 40));
      expect(
        polygon.center.x,
        (20 + 50 + 70 + 50 + 40 + 90 + 100 + 90 + 60 + 40) / 10,
      );
      expect(
        polygon.center.y,
        (40 + 30 + 60 + 40 + 60 + 80 + 20 + 50 + 10 + 25) / 10,
      );
      expect(polygon.aabb.min, Vector2(20, 10));
      expect(polygon.aabb.max, Vector2(100, 80));

      // containsPoint
      expect(polygon.containsPoint(Vector2(40, 25)), true);
      expect(polygon.containsPoint(Vector2(40, 30)), true);
      expect(polygon.containsPoint(Vector2(40, 60)), true);
      expect(polygon.containsPoint(Vector2(60, 20)), true);
      expect(polygon.containsPoint(Vector2(60, 30)), true);
      expect(polygon.containsPoint(Vector2(65, 25)), true);
      expect(polygon.containsPoint(Vector2(60, 40)), true);
      expect(polygon.containsPoint(Vector2(50, 50)), true);
      expect(polygon.containsPoint(Vector2(60, 60)), true);
      expect(polygon.containsPoint(Vector2(80, 40)), true);
      expect(polygon.containsPoint(Vector2(80, 70)), true);
      expect(polygon.containsPoint(Vector2(90, 80)), true);
      expect(polygon.containsPoint(Vector2(90, 50)), true);
      expect(polygon.containsPoint(Vector2(95, 50)), true);
      expect(polygon.containsPoint(Vector2(97, 30)), true);
      expect(polygon.containsPoint(Vector2(40, 40)), false);
      expect(polygon.containsPoint(Vector2(40, 50)), false);
      expect(polygon.containsPoint(Vector2(50, 35)), false);
      expect(polygon.containsPoint(Vector2(60, 49)), false);
    });
  });
}
