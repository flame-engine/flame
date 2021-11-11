import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('ShapeComponent.containsPoint tests', () {
    test('Simple circle contains point', () {
      final component = CircleComponent(
        radius: 1.0,
        position: Vector2(1, 1),
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2.all(1.5)),
        true,
      );
    });

    test('Simple rectangle contains point', () {
      final component = RectangleComponent(
        position: Vector2(1, 1),
        size: Vector2(1, 1),
      );
      expect(
        component.containsPoint(Vector2.all(1.5)),
        true,
      );
    });

    test('Simple polygon contains point', () {
      final component = PolygonComponent.fromPoints(
        [
          Vector2(2, 2),
          Vector2(2, 1),
          Vector2(2, 0),
          Vector2(1, 1),
        ],
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2(2.0, 1.9)),
        true,
      );
    });

    test('Rotated circle does not contain point', () {
      final component = CircleComponent(
        radius: 1.0,
        position: Vector2(1, 1),
        angle: pi / 4,
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2.all(1.9)),
        false,
      );
    });

    test('Rotated rectangle does not contain point', () {
      final component = RectangleComponent(
        position: Vector2.all(1.0),
        size: Vector2.all(2.0),
        angle: pi / 4,
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2.all(1.9)),
        false,
      );
    });

    test('Rotated polygon does not contain point', () {
      final component = PolygonComponent.fromPoints(
        [
          Vector2(2, 2),
          Vector2(2, 1),
          Vector2(2, 0),
          Vector2(1, 1),
        ],
        angle: pi / 4,
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2.all(1.9)),
        false,
      );
    });

    test('Rotated circle contains point', () {
      final component = CircleComponent(
        radius: 1.0,
        position: Vector2(1, 1),
        angle: pi / 4,
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2(1.0, 1.9)),
        true,
      );
    });

    test('Rotated rectangle contains point', () {
      final component = RectangleComponent(
        position: Vector2.all(1.0),
        size: Vector2.all(2.0),
        angle: pi / 4,
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2(1.0, 2.1)),
        true,
      );
    });

    test('Rotated polygon contains point', () {
      final component = PolygonComponent.fromPoints(
        [
          Vector2(2, 2),
          Vector2(3, 1),
          Vector2(2, 0),
          Vector2(1, 1),
        ],
        angle: pi / 4,
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2(2.7, 1.7)),
        true,
      );
    });

    test('Horizontally flipped rectangle contains point', () {
      final component = RectangleComponent(
        position: Vector2.all(1.0),
        size: Vector2.all(2.0),
        anchor: Anchor.center,
      )..flipVerticallyAroundCenter();
      expect(
        component.containsPoint(Vector2(2.0, 2.0)),
        true,
      );
    });

    test('Initially rotated CircleComponent does not contain point', () {
      final component = CircleComponent(
        radius: 1.0,
        position: Vector2(1, 1),
        angle: pi / 4,
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2.all(1.9)),
        false,
      );
    });

    test('Initially rotated RectangleComponent does not contain point', () {
      final component = RectangleComponent(
        position: Vector2.all(1.0),
        size: Vector2.all(2.0),
        angle: pi / 4,
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2.all(1.9)),
        false,
      );
    });

    test('Initially rotated PolygonComponent does not contain point', () {
      final component = PolygonComponent.fromPoints(
        [
          Vector2(2, 2),
          Vector2(3, 1),
          Vector2(2, 0),
          Vector2(1, 1),
        ],
        angle: pi / 4,
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2.all(1.9)),
        false,
      );
    });

    test('Rotated PolygonComponent contains point', () {
      final component = PolygonComponent.fromPoints(
        [
          Vector2(2, 2),
          Vector2(3, 1),
          Vector2(2, 0),
          Vector2(1, 1),
        ],
        anchor: Anchor.center,
      );
      component.angle = pi / 4;
      expect(
        component.containsPoint(Vector2(2.7, 1.7)),
        true,
      );
    });

    test('Moved CircleComponent contains point', () {
      final component = CircleComponent(
        radius: 1.0,
        position: Vector2(2, 2),
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2.all(2.1)),
        true,
      );
    });

    test('Moved RectangleComponent contains point', () {
      final component = RectangleComponent(
        position: Vector2(2, 2),
        size: Vector2(1, 1),
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2.all(2.1)),
        true,
      );
    });

    test('Moved PolygonComponent contains point', () {
      final component = PolygonComponent.fromPoints(
        [
          Vector2(2, 0),
          Vector2(1, 1),
          Vector2(2, 2),
          Vector2(3, 1),
        ],
        position: Vector2.all(1.0),
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2(0.9, 1.0)),
        true,
      );
    });

    test('Sized up CircleComponent does not contain point', () {
      final component = CircleComponent(
        radius: 1.0,
        position: Vector2(1, 1),
        anchor: Anchor.center,
      );
      component.size += Vector2.all(1.0);
      expect(
        component.containsPoint(Vector2.all(2.1)),
        false,
      );
    });

    test('Sized up RectangleComponent does not contain point', () {
      final component = RectangleComponent(
        position: Vector2(1, 1),
        size: Vector2(2, 2),
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2.all(2.1)),
        false,
      );
    });

    test('Sized PolygonComponent does not contain point', () {
      final component = PolygonComponent.fromPoints(
        [
          Vector2(2, 0),
          Vector2(1, 1),
          Vector2(2, 2),
          Vector2(3, 1),
        ],
        anchor: Anchor.center,
      );
      component.size += Vector2.all(1.0);
      expect(
        component.containsPoint(Vector2(2.0, 2.6)),
        false,
      );
    });

    test('CircleComponent with default anchor (topLeft) contains point', () {
      final component = CircleComponent(
        radius: 1.0,
        position: Vector2.all(1.0),
        angle: pi / 4,
      );
      expect(
        component.containsPoint(Vector2(0.9, 2.0)),
        true,
      );
    });

    test('RectangleComponent with default anchor (topLeft) contains point', () {
      final component = RectangleComponent(
        position: Vector2.all(1.0),
        size: Vector2.all(1.0),
        angle: pi / 4,
      );
      expect(
        component.containsPoint(Vector2(0.9, 2.0)),
        true,
      );
    });

    test('PolygonComponent with default anchor (topLeft) contains point', () {
      final component = PolygonComponent.fromPoints(
        [
          Vector2(2, 0),
          Vector2(1, 1),
          Vector2(2, 2),
          Vector2(3, 1),
        ],
        angle: pi / 4,
      );
      expect(
        component.containsPoint(Vector2(1.0, 0.99)),
        true,
      );
    });
  });
}
