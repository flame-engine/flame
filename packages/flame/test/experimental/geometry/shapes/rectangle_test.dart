import 'dart:ui';

import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rectangle', () {
    test('simple rectangle', () {
      final rectangle = Rectangle.fromLTRB(4, 0, 9, 12);
      expect(rectangle.left, 4);
      expect(rectangle.top, 0);
      expect(rectangle.right, 9);
      expect(rectangle.bottom, 12);
      expect(rectangle.width, 5);
      expect(rectangle.height, 12);
      expect(rectangle.isConvex, true);
      expect(rectangle.isClosed, true);
      expect(rectangle.perimeter, 34);
      expect(rectangle.center, closeToVector(6.5, 6));
      expect('$rectangle', 'Rectangle([4.0, 0.0], [9.0, 12.0])');
    });

    test('rectangle with inverted left-right edges', () {
      final rectangle = Rectangle.fromLTRB(3, 4, 0, 10);
      expect(rectangle.left, 0);
      expect(rectangle.right, 3);
      expect(rectangle.top, 4);
      expect(rectangle.bottom, 10);
    });

    test('rectangle with inverted top-bottom edges', () {
      final rectangle = Rectangle.fromLTRB(3, 4, 10, 0);
      expect(rectangle.left, 3);
      expect(rectangle.right, 10);
      expect(rectangle.top, 0);
      expect(rectangle.bottom, 4);
    });

    test('.fromPoints', () {
      final rectangles = [
        Rectangle.fromPoints(Vector2(2, 8), Vector2(5, 9)),
        Rectangle.fromPoints(Vector2(5, 9), Vector2(2, 8)),
        Rectangle.fromPoints(Vector2(5, 8), Vector2(2, 9)),
        Rectangle.fromPoints(Vector2(2, 9), Vector2(5, 8)),
      ];
      for (final rectangle in rectangles) {
        expect(rectangle.left, 2);
        expect(rectangle.right, 5);
        expect(rectangle.top, 8);
        expect(rectangle.bottom, 9);
      }
    });

    test('.fromRect', () {
      final rectangle = Rectangle.fromRect(const Rect.fromLTWH(5, 10, 3, 2));
      expect(rectangle.left, 5);
      expect(rectangle.top, 10);
      expect(rectangle.right, 5 + 3);
      expect(rectangle.bottom, 10 + 2);
    });

    test('fromRect with negative Rect', () {
      const rect = Rect.fromLTRB(5, 7, 1, 0);
      final rectangle = Rectangle.fromRect(rect);
      expect(rectangle.left, 1);
      expect(rectangle.right, 5);
      expect(rectangle.top, 0);
      expect(rectangle.bottom, 7);
    });

    test('0-size rectangle', () {
      final rectangle = Rectangle.fromLTRB(0, 0, 0, 0);
      expect(rectangle.left, 0);
      expect(rectangle.top, 0);
      expect(rectangle.right, 0);
      expect(rectangle.bottom, 0);
      expect(rectangle.width, 0);
      expect(rectangle.height, 0);
      expect(rectangle.perimeter, 0);
      expect(rectangle.containsPoint(Vector2.zero()), true);
      expect(rectangle.support(Vector2(2, 9)), Vector2.zero());
    });

    test('aabb', () {
      final rectangle = Rectangle.fromLTRB(4, 0, 9, 12);
      expect(
        rectangle.aabb,
        closeToAabb(Aabb2.minMax(Vector2(4, 0), Vector2(9, 12))),
      );
    });

    test('asPath', () {
      final rectangle = Rectangle.fromLTRB(3, 2, 8, 8);
      final path = rectangle.asPath();
      final metrics = path.computeMetrics().toList();
      expect(metrics.length, 1);
      expect(metrics[0].isClosed, true);
      expect(metrics[0].length, closeTo(rectangle.perimeter, 0.01));
    });

    test('containsPoint', () {
      final rectangle = Rectangle.fromLTRB(4, 2, 6, 5);
      expect(rectangle.containsPoint(Vector2(3, 2)), false);
      expect(rectangle.containsPoint(Vector2(4, 2)), true);
      expect(rectangle.containsPoint(Vector2(5, 2)), true);
      expect(rectangle.containsPoint(Vector2(6, 2)), true);
      expect(rectangle.containsPoint(Vector2(7, 2)), false);

      expect(rectangle.containsPoint(Vector2(3, 3)), false);
      expect(rectangle.containsPoint(Vector2(4, 3)), true);
      expect(rectangle.containsPoint(Vector2(5, 3)), true);
      expect(rectangle.containsPoint(Vector2(6, 3)), true);
      expect(rectangle.containsPoint(Vector2(7, 3)), false);

      expect(rectangle.containsPoint(Vector2(3, 4)), false);
      expect(rectangle.containsPoint(Vector2(4, 4)), true);
      expect(rectangle.containsPoint(Vector2(5, 4)), true);
      expect(rectangle.containsPoint(Vector2(6, 4)), true);
      expect(rectangle.containsPoint(Vector2(7, 4)), false);

      expect(rectangle.containsPoint(Vector2(3, 5)), false);
      expect(rectangle.containsPoint(Vector2(4, 5)), true);
      expect(rectangle.containsPoint(Vector2(5, 5)), true);
      expect(rectangle.containsPoint(Vector2(6, 5)), true);
      expect(rectangle.containsPoint(Vector2(7, 5)), false);

      expect(rectangle.containsPoint(Vector2(3, 6)), false);
      expect(rectangle.containsPoint(Vector2(4, 6)), false);
      expect(rectangle.containsPoint(Vector2(5, 6)), false);
      expect(rectangle.containsPoint(Vector2(6, 6)), false);
      expect(rectangle.containsPoint(Vector2(7, 6)), false);
    });

    test('move', () {
      final rectangle = Rectangle.fromLTRB(4, 2, 9, 12);
      expect(rectangle.aabb.min, closeToVector(4, 2));

      rectangle.move(Vector2(-3, 1));
      expect(rectangle.left, 4 - 3);
      expect(rectangle.right, 9 - 3);
      expect(rectangle.top, 2 + 1);
      expect(rectangle.bottom, 12 + 1);
      expect(rectangle.center, closeToVector(6.5 - 3, 7 + 1));
      expect(
        rectangle.aabb,
        closeToAabb(Aabb2.minMax(Vector2(1, 3), Vector2(6, 13))),
      );
    });

    test('project', () {
      final rectangle = Rectangle.fromLTRB(3, 3, 5, 5);
      final transform = Transform2D()
        ..position = Vector2(1, 1)
        ..scale = Vector2(-1, 4);
      final result = rectangle.project(transform);
      expect(result, isA<Rectangle>());
      expect((result as Rectangle).left, -4);
      expect(result.right, -2);
      expect(result.top, 13);
      expect(result.bottom, 21);

      transform.angle = 1;
      expect(
        () => rectangle.project(transform),
        throwsUnimplementedError,
      );
    });

    test('project with target', () {
      final rectangle = Rectangle.fromLTRB(0, 0, 1, 1);
      final transform = Transform2D()
        ..position = Vector2(3, 5)
        ..scale = Vector2(2, 1);
      expect(transform.isAxisAligned, true);

      final target = Rectangle.fromLTRB(0, 0, 0, 0);
      expect(target.aabb, closeToAabb(Aabb2()));
      final result = rectangle.project(transform, target);
      expect(result, isA<Rectangle>());
      expect(result, target);
      expect(target.left, 3);
      expect(target.right, 5);
      expect(target.top, 5);
      expect(target.bottom, 6);
      expect(
        target.aabb,
        closeToAabb(Aabb2.minMax(Vector2(3, 5), Vector2(5, 6))),
      );
    });

    test('support', () {
      final rectangle = Rectangle.fromLTRB(4, 2, 9, 3);

      // For axis-aligned directions, the support points are ambiguous, so test
      // only their unambiguous coordinates.
      expect(rectangle.support(Vector2(1, 0)).x, 9);
      expect(rectangle.support(Vector2(-1, 0)).x, 4);
      expect(rectangle.support(Vector2(0, 11)).y, 3);
      expect(rectangle.support(Vector2(0, -1)).y, 2);

      expect(rectangle.support(Vector2(1, 1)), closeToVector(9, 3));
      expect(rectangle.support(Vector2(-3, 2)), closeToVector(4, 3));
      expect(rectangle.support(Vector2(-0.13, -2.01)), closeToVector(4, 2));
      expect(rectangle.support(Vector2(9, -200)), closeToVector(9, 2));
    });
  });
}
