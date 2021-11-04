import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/src/geometry/circle.dart';
import 'package:test/test.dart';

void main() {
  group('ShapeComponent.containsPoint tests', () {
    test('Simple circle contains point', () {
      final shape = Circle(
        radius: 1.0,
        position: Vector2(1, 1),
      );
      final component = shape.toComponent();
      expect(
        component.containsPoint(Vector2.all(1.5)),
        true,
      );
    });

    test('Simple rectangle contains point', () {
      final shape = Rectangle(
        position: Vector2(1, 1),
        size: Vector2(1, 1),
      );
      final component = shape.toComponent();
      expect(
        component.containsPoint(Vector2.all(1.9)),
        true,
      );
    });

    test('Simple polygon contains point', () {
      final shape = Polygon([
        Vector2(2, 2),
        Vector2(2, 1),
        Vector2(2, 0),
        Vector2(1, 1),
      ]);
      final component = shape.toComponent();
      print(component.position);
      expect(
        component.containsPoint(Vector2(2.0, 1.9)),
        true,
      );
    });

    test('Rotated circle does not contain point', () {
      final shape = Circle(
        radius: 1.0,
        position: Vector2(1, 1),
        angle: pi / 2,
      );
      final component = shape.toComponent();
      expect(
        component.containsPoint(Vector2.all(1.9)),
        false,
      );
    });

    test('Rotated rectangle does not contain point', () {
      final shape = Rectangle(
        position: Vector2(1, 1),
        size: Vector2(1, 1),
        angle: pi / 2,
      );
      final component = shape.toComponent();
      expect(
        component.containsPoint(Vector2.all(1.9)),
        false,
      );
    });

    test('Rotated polygon does not contain point', () {
      final shape = Polygon(
        [
          Vector2(2, 2),
          Vector2(2, 1),
          Vector2(2, 0),
          Vector2(1, 1),
        ],
        angle: pi / 2,
      );
      final component = shape.toComponent();
      expect(
        component.containsPoint(Vector2.all(1.9)),
        false,
      );
    });

    test('Rotated CircleComponent does not contain point', () {
      final shape = Circle(
        radius: 1.0,
        position: Vector2(1, 1),
      );
      final component = shape.toComponent()..angle = pi / 2;
      expect(
        component.containsPoint(Vector2.all(1.9)),
        false,
      );
    });

    test('Rotated RectangleComponent does not contain point', () {
      final shape = Rectangle(
        position: Vector2(1, 1),
        size: Vector2(1, 1),
      );
      final component = shape.toComponent()..angle = pi / 2;
      expect(
        component.containsPoint(Vector2.all(1.9)),
        false,
      );
    });

    test('Rotated PolygonComponent does not contain point', () {
      final shape = Polygon([
        Vector2(2, 2),
        Vector2(2, 1),
        Vector2(2, 0),
        Vector2(1, 1),
      ]);
      final component = shape.toComponent()..angle = pi / 2;
      expect(
        component.containsPoint(Vector2.all(1.9)),
        false,
      );
    });

    test('Moved CircleComponent contains point', () {
      final shape = Circle(
        radius: 1.0,
        position: Vector2(1, 1),
      );
      final component = shape.toComponent()..position += Vector2.all(1.0);
      expect(
        component.containsPoint(Vector2.all(2.1)),
        true,
      );
    });

    test('Moved RectangleComponent contains point', () {
      final shape = Rectangle(
        position: Vector2(1, 1),
        size: Vector2(1, 1),
      );
      final component = shape.toComponent()..position += Vector2.all(1.0);
      expect(
        component.containsPoint(Vector2.all(2.1)),
        true,
      );
    });

    test('Moved PolygonComponent contains point', () {
      final shape = Polygon([
        Vector2(2, 2),
        Vector2(2, 1),
        Vector2(2, 0),
        Vector2(1, 1),
      ]);
      final component = shape.toComponent()..position += Vector2.all(1.0);
      expect(
        component.containsPoint(Vector2.all(2.1)),
        true,
      );
    });

    test('Sized up CircleComponent does not contain point', () {
      final shape = Circle(
        radius: 1.0,
        position: Vector2(1, 1),
      );
      final component = shape.toComponent()..size += Vector2.all(1.0);
      expect(
        component.containsPoint(Vector2.all(2.1)),
        false,
      );
    });

    test('Sized up RectangleComponent does not contain point', () {
      final shape = Rectangle(
        position: Vector2(1, 1),
        size: Vector2(1, 1),
      );
      final component = shape.toComponent()..size += Vector2.all(1.0);
      expect(
        component.containsPoint(Vector2.all(2.1)),
        false,
      );
    });

    test('Sized PolygonComponent does not contain point', () {
      final shape = Polygon([
        Vector2(2, 2),
        Vector2(2, 1),
        Vector2(2, 0),
        Vector2(1, 1),
      ]);
      final component = shape.toComponent()..size += Vector2.all(1.0);
      expect(
        component.containsPoint(Vector2.all(2.1)),
        false,
      );
    });
  });
}
