import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('PolygonComponent.globalVertices', () {
    final vertices = [
      Vector2(0, 0),
      Vector2(4, 0),
      Vector2(4, 2),
      Vector2(1, 3),
    ];

    testWithFlameGame('matches absolutePositionOf under nested transforms', (
      game,
    ) async {
      final polygon = PolygonComponent(
        vertices,
        position: Vector2(2, 1),
        angle: 0.3,
        scale: Vector2(1.5, 0.5),
        anchor: Anchor.center,
      );
      final parent = PositionComponent(
        position: Vector2(10, 20),
        size: Vector2(5, 5),
        angle: -1.1,
        scale: Vector2(2, 3),
        anchor: Anchor.center,
        children: [polygon],
      );
      final grandparent = PositionComponent(
        position: Vector2(-7, 3),
        angle: 0.7,
        children: [parent],
      );
      await game.ensureAdd(grandparent);

      final globalVertices = polygon.globalVertices();
      expect(globalVertices, hasLength(vertices.length));
      for (var i = 0; i < vertices.length; i++) {
        expect(
          globalVertices[i],
          closeToVector(polygon.absolutePositionOf(polygon.vertices[i]), 1e-4),
        );
      }
    });

    testWithFlameGame('is recomputed after an ancestor moves', (game) async {
      final polygon = PolygonComponent(vertices);
      final parent = PositionComponent(
        position: Vector2(10, 0),
        children: [polygon],
      );
      await game.ensureAdd(parent);

      final before = polygon.globalVertices().map((v) => v.clone()).toList();
      parent.position.add(Vector2(5, -2));
      final after = polygon.globalVertices();
      for (var i = 0; i < vertices.length; i++) {
        expect(after[i], closeToVector(before[i] + Vector2(5, -2), 1e-4));
      }
    });

    testWithFlameGame('is cached while nothing moves', (game) async {
      final polygon = PolygonComponent(vertices);
      await game.ensureAdd(PositionComponent(children: [polygon]));

      final first = polygon.globalVertices();
      final second = polygon.globalVertices();
      expect(identical(first, second), isTrue);
    });

    testWithFlameGame('is recomputed when only the vertices change', (
      game,
    ) async {
      final rectangle = RectangleComponent(
        position: Vector2(10, 20),
        size: Vector2(4, 2),
      );
      await game.ensureAdd(rectangle);

      expect(
        rectangle.globalVertices(),
        unorderedEquals([
          Vector2(10, 20),
          Vector2(14, 20),
          Vector2(14, 22),
          Vector2(10, 22),
        ]),
      );
      rectangle.size.setValues(8, 6);
      expect(
        rectangle.globalVertices(),
        unorderedEquals([
          Vector2(10, 20),
          Vector2(18, 20),
          Vector2(18, 26),
          Vector2(10, 26),
        ]),
      );
    });

    testWithFlameGame('stays counterclockwise under a mirrored ancestor', (
      game,
    ) async {
      final polygon = PolygonComponent(vertices);
      final mirrored = PolygonComponent(vertices);
      await game.ensureAddAll([
        PositionComponent(children: [polygon]),
        PositionComponent(scale: Vector2(-1, 1), children: [mirrored]),
      ]);

      expect(_signedArea(polygon.globalVertices()), isNegative);
      expect(_signedArea(mirrored.globalVertices()), isNegative);
    });
  });
}

/// The shoelace sum used by [PolygonComponent] to detect clockwise input,
/// which is negative for the counterclockwise order it keeps its vertices in.
double _signedArea(List<Vector2> vertices) {
  var area = 0.0;
  for (var i = 0; i < vertices.length; i++) {
    final j = (i + 1) % vertices.length;
    area += vertices[i].x * vertices[j].y - vertices[j].x * vertices[i].y;
  }
  return area;
}
