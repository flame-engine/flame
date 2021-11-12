import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
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
        isTrue,
      );
    });

    test('Simple rectangle contains point', () {
      final component = RectangleComponent(
        position: Vector2(1, 1),
        size: Vector2(1, 1),
      );
      expect(
        component.containsPoint(Vector2.all(1.5)),
        isTrue,
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
        isTrue,
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
        isFalse,
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
        isFalse,
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
        isFalse,
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
        isTrue,
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
        isTrue,
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
        isTrue,
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
        isTrue,
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
        isFalse,
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
        isFalse,
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
        isFalse,
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
        isTrue,
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
        isTrue,
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
        isTrue,
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
        isTrue,
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
        isFalse,
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
        isFalse,
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
        isFalse,
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
        isTrue,
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
        isTrue,
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
        isTrue,
      );
    });

    flameGame.test(
      'CircleComponent with multiple parents contains point',
      (game) async {
        PositionComponent createParent() {
          return PositionComponent(
            position: Vector2.all(1.0),
            size: Vector2.all(2.0),
            angle: pi / 2,
          );
        }

        final component = CircleComponent(
          radius: 1.0,
          position: Vector2.all(1.0),
          anchor: Anchor.center,
        );
        final grandParent = createParent();
        final parent = createParent();
        grandParent.add(parent);
        parent.add(component);
        await game.add(grandParent);
        expect(
          component.containsPoint(Vector2(-1.0, 1.0)),
          isTrue,
        );
      },
    );

    flameGame.test(
      'RectangleComponent with multiple parents contains point',
      (game) async {
        PositionComponent createParent() {
          return PositionComponent(
            position: Vector2.all(1.0),
            size: Vector2.all(2.0),
            angle: pi / 2,
          );
        }

        final component = RectangleComponent(
          size: Vector2.all(1.0),
          position: Vector2.all(1.0),
          anchor: Anchor.center,
        );
        final grandParent = createParent();
        final parent = createParent();
        grandParent.add(parent);
        parent.add(component);
        await game.add(grandParent);
        expect(
          component.containsPoint(Vector2(-1.0, 1.0)),
          isTrue,
        );
      },
    );

    flameGame.test(
      'PolygonComponent with multiple parents contains point',
      (game) async {
        PositionComponent createParent() {
          return PositionComponent(
            position: Vector2.all(1.0),
            size: Vector2.all(2.0),
            angle: pi / 2,
          );
        }

        final component = PolygonComponent(
          normalizedVertices: [
            Vector2(1, 0),
            Vector2(0, -1),
            Vector2(-1, 0),
            Vector2(0, 1),
          ],
          size: Vector2.all(1.0),
          position: Vector2.all(1.0),
          anchor: Anchor.center,
        );
        final grandParent = createParent();
        final parent = createParent();
        grandParent.add(parent);
        parent.add(component);
        await game.add(grandParent);
        expect(
          component.containsPoint(Vector2(-1.0, 1.0)),
          isTrue,
        );
      },
    );
  });
}
