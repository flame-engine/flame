import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
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
