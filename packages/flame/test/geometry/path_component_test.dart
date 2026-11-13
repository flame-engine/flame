import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flame_test/test_paths.dart';
import 'package:test/test.dart';

void main() {
  group('PathComponent', () {
    test('roundRect preserves the path bounds', () {
      const size = Size(64, 64);
      final path = TestPaths.byName('roundRect', size);

      final pathComponent = PathComponent(path: path);

      expect(pathComponent.width, closeTo(size.width, 1e-10));
      expect(pathComponent.height, closeTo(size.height, 1e-10));
    });

    test('flame preserves the path bounds', () {
      const size = Size(64, 64);
      final path = TestPaths.byName('flame', size);
      final pathSize = path.getBounds().size;

      final pathComponent = PathComponent(path: path);

      expect(pathComponent.width, pathSize.width);
      expect(pathComponent.height, pathSize.height);
    });

    test('invader1 preserves the aspect ratio', () {
      const size = Size(64, 64);
      final path = TestPaths.byName('invader1', size);

      final invader1 = TestPaths.invader1();
      final invader1Size = invader1.getBounds().size;
      final scaleX = size.width / invader1Size.width;
      final scaleY = size.height / invader1Size.height;
      final scale = min(scaleX, scaleY);

      final pathComponent = PathComponent(path: path);
      expect(pathComponent.width, closeTo(invader1Size.width * scale, 1e-6));
      expect(pathComponent.height, closeTo(invader1Size.height * scale, 1e-6));
    });

    test('invader2 keeps only one disjoint contour', () {
      const size = Size(64, 64);
      final path = TestPaths.byName('invader2', size);
      final pathComponent = PathComponent(path: path);

      expect(pathComponent.polygons.length, 1);
    });

    test('invader2 explicitly keeps all contours', () {
      const size = Size(64, 64);
      final path = TestPaths.byName('invader2', size);

      final pathComponent = PathComponent(path: path, filter: false);

      expect(pathComponent.polygons.length, 3);
    });

    test('alien2 implicitly keeps all disjoint contours', () {
      const size = Size(64, 64);
      final path = TestPaths.byName('alien2', size);
      final pathComponent = PathComponent(path: path);

      expect(pathComponent.polygons.length, 4);
    });

    test('invader3 respects the given tolerance', () {
      const size = Size(64, 64);
      final path = TestPaths.byName('invader3', size);

      final path1 = PathComponent(path: path);
      final path2 = PathComponent(path: path, tolerance: 1);

      expect(
        path1.polygons.first.length,
        greaterThan(path2.polygons.first.length),
      );
    });

    test('an open contour does not become a polygon', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(10, 0)
        ..lineTo(10, 10);
      final pathComponent = PathComponent(path: path);

      expect(pathComponent.polygons, isEmpty);
      expect(pathComponent.containsLocalPoint(Vector2(9, 1)), isFalse);
    });

    test('the polygons go counterclockwise', () {
      final path = Path()..addRect(const Rect.fromLTWH(0, 0, 10, 10));
      final pathComponent = PathComponent(path: path);

      expect(
        PolygonComponent.isClockwise(pathComponent.polygons.first),
        isFalse,
      );
    });

    test('the polygons are the ones of the path moved to the origin', () {
      final path = Path()
        ..addRect(const Rect.fromLTWH(5, 5, 10, 10))
        ..addRect(const Rect.fromLTWH(7, 7, 2, 2));
      final polygons = path.toPolygons();
      final component = PathComponent(path: path);

      expect(polygons, hasLength(1));
      expect(
        polygons.single.map((vertex) => vertex - Vector2.all(5)),
        component.polygons.single,
      );
    });

    test('takes the given polygons instead of sampling the path', () {
      final path = Path()..addRect(const Rect.fromLTWH(5, 5, 10, 10));
      final triangle = [Vector2(5, 5), Vector2(5, 15), Vector2(15, 15)];
      final component = PathComponent(path: path, polygons: [triangle]);

      expect(
        component.polygons.single,
        triangle.map((vertex) => vertex - Vector2.all(5)),
      );
    });

    test('the polygons of the path give the sampled ones', () {
      final path = Path()
        ..addOval(const Rect.fromLTWH(5, 5, 40, 20))
        ..addOval(const Rect.fromLTWH(60, 5, 20, 20));
      final sampled = PathComponent(path: path, sampling: 2);
      final given = PathComponent(
        path: path,
        polygons: path.toPolygons(sampling: 2),
      );

      expect(given.polygons, hasLength(sampled.polygons.length));
      for (var i = 0; i < sampled.polygons.length; i++) {
        expect(given.polygons[i], hasLength(sampled.polygons[i].length));
        for (var j = 0; j < sampled.polygons[i].length; j++) {
          expect(
            given.polygons[i][j],
            closeToVector(sampled.polygons[i][j], 1e-4),
          );
        }
      }
    });

    test('the polygons of a component give it again', () {
      final path = Path()..addOval(const Rect.fromLTWH(5, 5, 40, 20));
      final first = PathComponent(path: path);
      final second = PathComponent(
        path: first.path,
        polygons: first.polygons,
      );

      expect(second.polygons, first.polygons);
    });

    test('copies the given polygons', () {
      final path = Path()..addRect(const Rect.fromLTWH(0, 0, 10, 10));
      final polygons = path.toPolygons();
      final component = PathComponent(path: path, polygons: polygons);
      polygons.single.first.setValues(100, 100);
      polygons.clear();

      expect(
        component.polygons.single,
        PathComponent(path: path).polygons.single,
      );
    });

    test('needs given polygons of three counterclockwise vertices', () {
      final path = Path()..addRect(const Rect.fromLTWH(0, 0, 10, 10));

      expect(
        () => PathComponent(
          path: path,
          polygons: [
            [Vector2(0, 0), Vector2(10, 10)],
          ],
        ),
        failsAssert(),
      );
      expect(
        () => PathComponent(
          path: path,
          polygons: [
            [Vector2(0, 0), Vector2(10, 0), Vector2(10, 10)],
          ],
        ),
        failsAssert(),
      );
    });

    test('contains the points inside of any polygon', () {
      final path = Path()
        ..addRect(const Rect.fromLTWH(0, 0, 10, 10))
        ..addRect(const Rect.fromLTWH(20, 0, 10, 10));
      final pathComponent = PathComponent(path: path);

      expect(pathComponent.containsLocalPoint(Vector2(5, 5)), isTrue);
      expect(pathComponent.containsLocalPoint(Vector2(25, 5)), isTrue);
      expect(pathComponent.containsLocalPoint(Vector2(15, 5)), isFalse);
      expect(pathComponent.containsPoint(Vector2(5, 5)), isTrue);
      expect(pathComponent.containsPoint(Vector2(15, 5)), isFalse);
    });

    test('contains the points inside of a transformed polygon', () {
      final path = Path()..addRect(const Rect.fromLTWH(0, 0, 10, 10));
      final pathComponent = PathComponent(
        path: path,
        position: Vector2(100, 100),
        anchor: Anchor.center,
        angle: pi / 4,
      );

      expect(pathComponent.containsPoint(Vector2(100, 100)), isTrue);
      expect(pathComponent.containsPoint(Vector2(106, 100)), isTrue);
      expect(pathComponent.containsPoint(Vector2(105, 105)), isFalse);
    });
  });
}
