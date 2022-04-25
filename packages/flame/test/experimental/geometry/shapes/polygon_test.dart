import 'dart:math';

import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Polygon', () {
    test('invalid polygon', () {
      expect(
        () => Polygon([]),
        failsAssert('At least 3 vertices are required'),
      );
      expect(
        () => Polygon([Vector2(1, 5), Vector2.zero()]),
        failsAssert('At least 3 vertices are required'),
      );
    });

    test('simple triangle', () {
      final polygon = Polygon(
        [Vector2.zero(), Vector2(0, 60), Vector2(80, 60)],
      );
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

    test('explicit `convex` flag', () {
      final polygon = Polygon(
        [Vector2(0, 60), Vector2.zero(), Vector2(80, 60)],
        convex: true,
      );
      // The polygon is marked as "convex", but the vertices are in the wrong
      // order. As a result, all points will be detected as being "outside".
      expect(polygon.isConvex, true);
      expect(polygon.vertices[0], Vector2(0, 60));
      expect(polygon.vertices[1], Vector2(0, 0));
      expect(polygon.vertices[2], Vector2(80, 60));
      expect(polygon.containsPoint(Vector2(0, 0)), false);
      expect(polygon.containsPoint(Vector2(10, 30)), false);
      expect(polygon.containsPoint(Vector2(-10, 30)), false);
      expect(polygon.containsPoint(Vector2(100, 30)), false);
      expect(polygon.containsPoint(Vector2(100, 100)), false);
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
      expect(polygon.edges.length, 10);
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
      expect(polygon.containsPoint(Vector2(90, 40)), false);
      expect(polygon.containsPoint(Vector2(100, 40)), false);
    });

    test('project', () {
      final polygon = Polygon([
        Vector2(0, 20),
        Vector2(20, 40),
        Vector2(40, 20),
        Vector2(20, 0),
      ]);
      expect(polygon.isConvex, true);
      final transform = Transform2D()
        ..angle = pi / 4
        ..offset = Vector2(-20, -20);
      final result = polygon.project(transform);
      final a = 10 * sqrt(2);
      expect(result, isA<Polygon>());
      expect((result as Polygon).edges.length, 4);
      expect(result.vertices[0], closeToVector(-a, -a, epsilon: 1e-14));
      expect(result.vertices[1], closeToVector(-a, a, epsilon: 1e-14));
      expect(result.vertices[2], closeToVector(a, a, epsilon: 1e-14));
      expect(result.vertices[3], closeToVector(a, -a, epsilon: 1e-14));
    });

    test('project with target', () {
      final polygon = Polygon([
        Vector2(0, 20),
        Vector2(20, 40),
        Vector2(40, 20),
        Vector2(20, 0),
      ]);
      final transform = Transform2D()
        ..position = Vector2(10, 10)
        ..scale = Vector2(2, 1);
      final target = Polygon(List.generate(4, (_) => Vector2.zero()));
      final result = polygon.project(transform, target);
      expect(result, isA<Polygon>());
      expect(result, target);
      expect((result as Polygon).edges.length, 4);
      expect(result.vertices[0], Vector2(10, 30));
      expect(result.vertices[1], Vector2(50, 50));
      expect(result.vertices[2], Vector2(90, 30));
      expect(result.vertices[3], Vector2(50, 10));
    });

    test('project with target and reflection transform', () {
      final polygon = Polygon([
        Vector2(0, 20),
        Vector2(20, 40),
        Vector2(40, 20),
        Vector2(20, 0),
      ]);
      final transform = Transform2D()
        ..position = Vector2(10, 10)
        ..scale = Vector2(-2, 1);
      final target = Polygon(List.generate(4, (_) => Vector2.zero()));
      final result = polygon.project(transform, target);
      expect(result, isA<Polygon>());
      expect(result, target);
      expect((result as Polygon).edges.length, 4);
      expect(result.isConvex, true);
      expect(result.vertices[0], Vector2(-30, 10));
      expect(result.vertices[1], Vector2(-70, 30));
      expect(result.vertices[2], Vector2(-30, 50));
      expect(result.vertices[3], Vector2(10, 30));
    });

    test('project with wrong-shape target', () {
      final z = Vector2.zero();
      final polygon = Polygon([z, z, z, z, z]);
      final target = Polygon([z, z, z]);
      final transform = Transform2D()..angle = 1;
      final result = polygon.project(transform, target);
      expect(result == target, false);
      expect(result, isA<Polygon>());
      expect((result as Polygon).edges.length, 5);
      expect(target.edges.length, 3);
      expect(result.vertices, [z, z, z, z, z]);
      expect(result.edges, [z, z, z, z, z]);
      expect(result.isConvex, true);
    });
  });
}
