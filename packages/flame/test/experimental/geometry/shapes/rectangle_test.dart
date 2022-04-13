import 'dart:ui';

import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('Rectangle', () {
    test('simple properties', () {
      final rectangle = Rectangle.fromLTRB(4, 0, 9, 12);
      expect(rectangle.left, 4);
      expect(rectangle.top, 0);
      expect(rectangle.right, 9);
      expect(rectangle.bottom, 12);
      expect(rectangle.isConvex, true);
      expect(rectangle.isClosed, true);
      expect(rectangle.perimeter, 34);
      expect(rectangle.center, closeToVector(6.5, 6));
      expect('$rectangle', 'Rectangle([4.0, 0.0], [9.0, 12.0])');
    });

    test('invalid rectangles', () {
      expect(
        () => Rectangle.fromLTRB(3, 3, 0, 10),
        failsAssert(),
      );
      expect(
        () => Rectangle.fromLTRB(3, 3, 10, 0),
        failsAssert(),
      );
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
      expect(rectangle.containsPoint(Vector2(6, 2)), false);
      expect(rectangle.containsPoint(Vector2(7, 2)), false);

      expect(rectangle.containsPoint(Vector2(3, 3)), false);
      expect(rectangle.containsPoint(Vector2(4, 3)), true);
      expect(rectangle.containsPoint(Vector2(5, 3)), true);
      expect(rectangle.containsPoint(Vector2(6, 3)), false);
      expect(rectangle.containsPoint(Vector2(7, 3)), false);

      expect(rectangle.containsPoint(Vector2(3, 4)), false);
      expect(rectangle.containsPoint(Vector2(4, 4)), true);
      expect(rectangle.containsPoint(Vector2(5, 4)), true);
      expect(rectangle.containsPoint(Vector2(6, 4)), false);
      expect(rectangle.containsPoint(Vector2(7, 4)), false);

      expect(rectangle.containsPoint(Vector2(3, 5)), false);
      expect(rectangle.containsPoint(Vector2(4, 5)), false);
      expect(rectangle.containsPoint(Vector2(5, 5)), false);
      expect(rectangle.containsPoint(Vector2(6, 5)), false);
      expect(rectangle.containsPoint(Vector2(7, 5)), false);
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
  });
}
