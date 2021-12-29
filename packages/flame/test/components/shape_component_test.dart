import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('ShapeComponent.containsPoint', () {
    test('circle contains point', () {
      final component = Circle(
        radius: 1.0,
        position: Vector2(1, 1),
        anchor: Anchor.center,
      );
      expect(
        component.containsPoint(Vector2.all(1.5)),
        isTrue,
      );
    });

    test('rectangle contains point', () {
      final component = RectangleComponent(
        position: Vector2(1, 1),
        size: Vector2(1, 1),
      );
      expect(
        component.containsPoint(Vector2.all(1.5)),
        isTrue,
      );
    });

    test('polygon contains point', () {
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

    test('rotated circle does not contain point', () {
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

    test('rotated rectangle does not contain point', () {
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

    test('rotated polygon does not contain point', () {
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

    test('rotated circle contains point', () {
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

    test('rotated rectangle contains point', () {
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

    test('rotated polygon contains point', () {
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

    test('horizontally flipped rectangle contains point', () {
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

    test('initially rotated CircleComponent does not contain point', () {
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

    test('initially rotated RectangleComponent does not contain point', () {
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

    test('initially rotated PolygonComponent does not contain point', () {
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

    test('rotated PolygonComponent contains point', () {
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

    test('moved CircleComponent contains point', () {
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

    test('moved RectangleComponent contains point', () {
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

    test('moved PolygonComponent contains point', () {
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

    test('sized up CircleComponent does not contain point', () {
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

    test('sized up RectangleComponent does not contain point', () {
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

    test('sized PolygonComponent does not contain point', () {
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

    test(
      'rotated CircleComponent with default anchor (topLeft) contains point',
      () {
        final component = CircleComponent(
          radius: 1.0,
          position: Vector2.all(1.0),
          angle: pi / 4,
        );
        expect(
          component.containsPoint(Vector2(0.9, 2.0)),
          isTrue,
        );
      },
    );

    test(
      'rotated RectangleComponent with default anchor (topLeft) contains point',
      () {
        final component = RectangleComponent(
          position: Vector2.all(1.0),
          size: Vector2.all(1.0),
          angle: pi / 4,
        );
        expect(
          component.containsPoint(Vector2(0.9, 2.0)),
          isTrue,
        );
      },
    );

    test(
      'rotated PolygonComponent with default anchor (topLeft) contains point',
      () {
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
      },
    );

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
        game.add(grandParent);
        await game.ready();
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
        game.add(grandParent);
        await game.ready();
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
        game.add(grandParent);
        await game.ready();
        expect(
          component.containsPoint(Vector2(-1.0, 1.0)),
          isTrue,
        );
      },
    );
  });
}
