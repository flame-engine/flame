import 'dart:math';
import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('PositionComponent', () {
    group('Properties getters and setters', () {
      test('get/set x/y or position', () {
        final component = PositionComponent();
        component.position.setValues(2.2, 3.4);
        expect(component.x, 2.2);
        expect(component.y, 3.4);

        component.position = Vector2(1.0, 0.0);
        expect(component.x, 1.0);
        expect(component.y, 0.0);

        component.x = 3.1;
        component.y = -2.2;
        expect(component.position, Vector2(3.1, -2.2));
      });

      test('get/set width/height or size', () {
        final component = PositionComponent();
        component.size.setValues(2.2, 3.4);
        expect(component.size.x, 2.2);
        expect(component.size.y, 3.4);

        component.size = Vector2(1.0, 0.0);
        expect(component.width, 1.0);
        expect(component.height, 0.0);

        component.width = 2.1;
        component.height = 3.3;
        expect(component.size, Vector2(2.1, 3.3));
      });

      test('get/set rect', () {
        final component = PositionComponent(
          position: Vector2(0, 1),
          size: Vector2.all(2),
        );
        final rect = component.toRect();
        expect(rect, const Rect.fromLTWH(0, 1, 2, 2));

        component.setByRect(const Rect.fromLTWH(10.0, 10.0, 1.0, 1.0));
        expect(component.x, 10.0);
        expect(component.y, 10.0);
        expect(component.width, 1.0);
        expect(component.height, 1.0);
      });

      test('get/set rect with anchor', () {
        final component = PositionComponent(
          position: Vector2(0, 1),
          size: Vector2.all(2),
          anchor: Anchor.center,
        );
        final rect = component.toRect();
        expect(rect.left, -1.0);
        expect(rect.top, 0.0);
        expect(rect.width, 2.0);
        expect(rect.height, 2.0);
        expect(component.topLeftPosition, Vector2(-1.0, 0));

        component.setByRect(const Rect.fromLTWH(10.0, 10.0, 1.0, 1.0));
        expect(component.x, 10.5);
        expect(component.y, 10.5);
        expect(component.width, 1.0);
        expect(component.height, 1.0);
      });
    });

    group('Contains point', () {
      test('inside point', () {
        final component = PositionComponent()
          ..position = Vector2(2.0, 2.0)
          ..size = Vector2(4.0, 4.0)
          ..angle = 0.0
          ..anchor = Anchor.center;

        final point = Vector2(2.0, 2.0);
        expect(component.containsPoint(point), true);
      });

      test('point on edge', () {
        final component = PositionComponent();
        component.position.setValues(2.0, 2.0);
        component.size.setValues(2.0, 2.0);
        component.angle = 0.0;
        component.anchor = Anchor.center;

        final point = Vector2(1.0, 1.0);
        expect(component.containsPoint(point), true);
      });

      test('points outside', () {
        final component = PositionComponent();
        component.position.setValues(2.0, 2.0);
        component.size.setValues(2.0, 2.0);
        component.angle = 0.0;
        component.anchor = Anchor.center;

        expect(component.containsPoint(Vector2(4.0, 1.0)), false);
        expect(component.containsPoint(Vector2(1.0, 4.0)), false);
      });

      test('overlapping with angle', () {
        final component = PositionComponent();
        component.position.setValues(2.0, 2.0);
        component.size.setValues(2.0, 2.0);
        component.angle = pi / 4;
        component.anchor = Anchor.center;

        final point = Vector2(3.1, 2.0);
        expect(component.containsPoint(point), true);
      });

      test('not overlapping with angle', () {
        final component = PositionComponent();
        component.position.setValues(2.0, 2.0);
        component.size.setValues(2.0, 2.0);
        component.angle = pi / 4;
        component.anchor = Anchor.center;

        final point = Vector2(1.0, 0.1);
        expect(component.containsPoint(point), false);
      });

      test('overlapping with angle and topLeft anchor', () {
        final component = PositionComponent();
        component.position.setValues(1.0, 1.0);
        component.size.setValues(2.0, 2.0);
        component.angle = pi / 4;
        component.anchor = Anchor.topLeft;

        final point = Vector2(1.0, 3.1);
        expect(component.containsPoint(point), true);
      });

      testWithFlameGame('component with hitbox contains point', (game) async {
        final component = _MyHitboxComponent();
        component.position.setValues(1.0, 1.0);
        component.anchor = Anchor.topLeft;
        component.size.setValues(2.0, 2.0);
        final hitbox = PolygonHitbox([
          Vector2(1, 0),
          Vector2(0, -1),
          Vector2(-1, 0),
          Vector2(0, 1),
        ]);
        component.add(hitbox);
        await game.ensureAdd(component);

        final point = component.position + component.size / 4;
        expect(component.containsPoint(point), true);
      });

      testWithFlameGame('component with hitbox with position contains point',
          (game) async {
        final component = _MyHitboxComponent();
        component.position.setValues(1.0, 1.0);
        component.anchor = Anchor.topLeft;
        component.size.setValues(2.0, 2.0);
        final hitbox = PolygonHitbox(
          [
            Vector2(1, 0),
            Vector2(0, -1),
            Vector2(-1, 0),
            Vector2(0, 1),
          ],
          position: Vector2(5, 6),
        );
        component.add(hitbox);
        await game.ensureAdd(component);

        final point =
            component.position + (component.size / 4) + hitbox.position;
        expect(component.containsPoint(point), true);
      });

      testWithFlameGame('component with hitbox with position just misses point',
          (game) async {
        final component = _MyHitboxComponent();
        component.position.setValues(1.0, 1.0);
        component.anchor = Anchor.topLeft;
        component.size.setValues(2.0, 2.0);
        final hitbox = PolygonHitbox(
          [
            Vector2(1, 0),
            Vector2(0, -1),
            Vector2(-1, 0),
            Vector2(0, 1),
          ],
          position: Vector2(5, 6),
        );
        component.add(hitbox);
        await game.ensureAdd(component);

        final point = component.position +
            (component.size / 4) -
            Vector2(0.01, 0) +
            hitbox.position;
        expect(component.containsPoint(point), false);
      });

      testWithFlameGame(
        'component with anchor topLeft contains point on edge',
        (game) async {
          final component = _MyHitboxComponent();
          component.position.setValues(-1, -1);
          component.anchor = Anchor.topLeft;
          component.size.setValues(2.0, 2.0);
          component.add(RectangleHitbox());
          await game.ensureAdd(component);

          expect(component.containsPoint(Vector2(1, 1)), true);
          expect(component.containsPoint(Vector2(1, -1)), true);
          expect(component.containsPoint(Vector2(-1, -1)), true);
          expect(component.containsPoint(Vector2(-1, 1)), true);
        },
      );

      testWithFlameGame(
        'component with anchor bottomRight contains point on edge',
        (game) async {
          final component = _MyHitboxComponent();
          component.position.setValues(1, 1);
          component.anchor = Anchor.bottomRight;
          component.size.setValues(2.0, 2.0);
          component.add(RectangleHitbox());
          await game.ensureAdd(component);

          expect(component.containsPoint(Vector2(1, 1)), true);
          expect(component.containsPoint(Vector2(1, -1)), true);
          expect(component.containsPoint(Vector2(-1, -1)), true);
          expect(component.containsPoint(Vector2(-1, 1)), true);
        },
      );

      test('component with anchor topRight does not contain close points', () {
        final component = _MyHitboxComponent();
        component.position.setValues(1, 1);
        component.anchor = Anchor.topLeft;
        component.size.setValues(2.0, 2.0);
        final hitbox = RectangleHitbox();
        component.add(hitbox);

        expect(component.containsPoint(Vector2(0.0, 0.0)), false);
        expect(component.containsPoint(Vector2(0.9, 0.9)), false);
        expect(component.containsPoint(Vector2(3.1, 3.1)), false);
        expect(component.containsPoint(Vector2(1.1, 3.1)), false);
      });

      test('component with hitbox does not contains point', () {
        final component = _MyHitboxComponent();
        component.position.setValues(1.0, 1.0);
        component.anchor = Anchor.topLeft;
        component.size.setValues(2.0, 2.0);
        component.add(
          PolygonHitbox([
            Vector2(1, 0),
            Vector2(0, -1),
            Vector2(-1, 0),
            Vector2(0, 1),
          ]),
        );

        final point = Vector2(1.1, 1.1);
        expect(component.containsPoint(point), false);
      });

      test('component with zero size does not contain point', () {
        final component = PositionComponent();
        component.position.setValues(2.0, 2.0);
        component.size.setValues(0.0, 0.0);
        component.angle = 0.0;
        component.anchor = Anchor.center;

        final point = Vector2(2.0, 2.0);
        expect(component.containsPoint(point), false);
      });

      test('component with zero size does not contain point', () {
        final component = PositionComponent();
        component.position.setValues(2.0, 2.0);
        component.size.setValues(0.0, 0.0);
        component.angle = 0.0;
        component.anchor = Anchor.center;

        final point = Vector2(2.0, 2.0);
        expect(component.containsPoint(point), false);
      });

      test('scaled component contains point', () {
        final component = PositionComponent();
        component.anchor = Anchor.center;
        component.position = Vector2.all(10.0);
        component.size = Vector2.all(5.0);

        final topLeftPoint = component.position - component.size / 2;
        final bottomRightPoint = component.position + component.size / 2;
        final topRightPoint = Vector2(bottomRightPoint.x, topLeftPoint.y);
        final bottomLeftPoint = Vector2(topLeftPoint.x, bottomRightPoint.y);
        final epsilon = Vector2.all(0.0001);
        void checkOutsideCorners(
          bool expectedResult, {
          bool? topLeftResult,
          bool? bottomRightResult,
          bool? topRightResult,
          bool? bottomLeftResult,
        }) {
          expect(
            component.containsPoint(topLeftPoint - epsilon),
            topLeftResult ?? expectedResult,
          );
          expect(
            component.containsPoint(bottomRightPoint + epsilon),
            bottomRightResult ?? expectedResult,
          );
          expect(
            component.containsPoint(
              topRightPoint
                ..x += epsilon.x
                ..y -= epsilon.y,
            ),
            topRightResult ?? expectedResult,
          );
          expect(
            component.containsPoint(
              bottomLeftPoint
                ..x -= epsilon.x
                ..y += epsilon.y,
            ),
            bottomLeftResult ?? expectedResult,
          );
        }

        checkOutsideCorners(false);
        component.scale = Vector2.all(1.0001);
        checkOutsideCorners(true);
        component.angle = 1;
        checkOutsideCorners(false);
        component.angle = 0;
        component.anchor = Anchor.topLeft;
        checkOutsideCorners(false, bottomRightResult: true);
        component.anchor = Anchor.bottomRight;
        checkOutsideCorners(false, topLeftResult: true);
        component.anchor = Anchor.topRight;
        checkOutsideCorners(false, bottomLeftResult: true);
        component.anchor = Anchor.bottomLeft;
        checkOutsideCorners(false, topRightResult: true);
      });
    });

    group('Anchor points', () {
      test('component with anchor center has the same center and position', () {
        final component = PositionComponent();
        component.position.setValues(2.0, 1.0);
        component.size.setValues(3.0, 1.0);
        component.anchor = Anchor.center;

        expect(component.center, component.position);
        expect(component.absoluteCenter, component.position);
        expect(
          component.topLeftPosition,
          component.position - component.size / 2,
        );
      });

      test('component with anchor topLeft has the correct center', () {
        final component = PositionComponent();
        component.position.setValues(2.0, 1.0);
        component.size.setValues(3.0, 1.0);
        component.angle = 0.0;
        component.anchor = Anchor.topLeft;

        expect(component.center, component.position + component.size / 2);
        expect(
          component.absoluteCenter,
          component.position + component.size / 2,
        );
      });

      test('component with parent has the correct center', () async {
        final game = FlameGame()..onGameResize(Vector2.all(100));
        final parent = PositionComponent();
        parent.position.setValues(2.0, 1.0);
        parent.anchor = Anchor.topLeft;
        final child = PositionComponent();
        child.position.setValues(2.0, 1.0);
        child.size.setValues(3.0, 1.0);
        child.angle = 0.0;
        child.anchor = Anchor.topLeft;
        parent.add(child);
        game.add(parent);
        await game.ready();

        expect(child.absoluteTopLeftPosition, child.position + parent.position);
        expect(
          child.absoluteTopLeftPosition,
          child.topLeftPosition + parent.topLeftPosition,
        );
        expect(child.absoluteCenter, parent.position + child.center);
      });
    });

    group('Coordinates transforms', () {
      final game = FlameGame();
      game.onGameResize(Vector2.all(100));

      test('width and height', () {
        final component = PositionComponent(size: Vector2.all(3));
        component.scale = Vector2(5, -7);
        expect(component.width, 3);
        expect(component.height, 3);
        expect(component.scaledSize.x, 15);
        expect(component.scaledSize.y, 21);
        component.width = 1;
        component.height = 2;
        expect(component.width, 1);
        expect(component.height, 2);
        expect(component.scaledSize.x, 5);
        expect(component.scaledSize.y, 14);
        // Changing scaledSize won't have any effect...
        component.scaledSize.setValues(1, 1);
        expect(component.scaledSize.x, 5);
        expect(component.scaledSize.y, 14);
      });

      test('positionOf', () {
        final component = PositionComponent()
          ..size = Vector2(50, 100)
          ..position = Vector2(500, 700)
          ..scale = Vector2(2, 1)
          ..anchor = Anchor.center;
        expect(component.positionOfAnchor(Anchor.center), Vector2(500, 700));
        expect(component.positionOfAnchor(Anchor.topLeft), Vector2(450, 650));
        expect(component.positionOfAnchor(Anchor.topCenter), Vector2(500, 650));
        expect(component.positionOfAnchor(Anchor.topRight), Vector2(550, 650));
        expect(
          component.positionOfAnchor(Anchor.centerLeft),
          Vector2(450, 700),
        );
        expect(
          component.positionOfAnchor(Anchor.centerRight),
          Vector2(550, 700),
        );
        expect(
          component.positionOfAnchor(Anchor.bottomLeft),
          Vector2(450, 750),
        );
        expect(
          component.positionOfAnchor(Anchor.bottomCenter),
          Vector2(500, 750),
        );
        expect(
          component.positionOfAnchor(Anchor.bottomRight),
          Vector2(550, 750),
        );
        expect(component.positionOf(Vector2(-3, 2)), Vector2(444, 652));
        expect(component.positionOf(Vector2(7, 16)), Vector2(464, 666));
      });

      test('local<->parent transforms', () {
        final component = PositionComponent()
          ..size = Vector2(10, 10)
          ..position = Vector2(50, 20)
          ..anchor = Anchor.center;

        expect(component.positionOf(Vector2(0, 0)), Vector2(45, 15));
        expect(component.positionOf(Vector2(5, 5)), Vector2(50, 20));
        expect(component.positionOf(Vector2(10, 0)), Vector2(55, 15));
        expect(component.positionOf(Vector2(0, 10)), Vector2(45, 25));

        expect(component.toLocal(Vector2(0, 0)), Vector2(-45, -15));
        expect(component.toLocal(Vector2(50, 20)), Vector2(5, 5));
        expect(component.toLocal(Vector2(55, 25)), Vector2(10, 10));
        expect(component.toLocal(Vector2(100, 100)), Vector2(55, 85));
      });

      test('flips', () {
        final component = PositionComponent()
          ..size = Vector2(10, 10)
          ..position = Vector2(50, 20)
          ..anchor = const Anchor(0.6, 0.8);

        expect(component.positionOf(Vector2(6, 8)), Vector2(50, 20));
        expect(component.positionOf(Vector2(0, 0)), Vector2(44, 12));
        component.flipHorizontally();
        expect(component.positionOf(Vector2(6, 8)), Vector2(50, 20));
        expect(component.positionOf(Vector2(0, 0)), Vector2(56, 12));
        component.flipVertically();
        expect(component.positionOf(Vector2(6, 8)), Vector2(50, 20));
        expect(component.positionOf(Vector2(0, 0)), Vector2(56, 28));
        component.flipHorizontally();
        expect(component.positionOf(Vector2(6, 8)), Vector2(50, 20));
        expect(component.positionOf(Vector2(0, 0)), Vector2(44, 28));
        component.flipVertically();
        expect(component.positionOf(Vector2(6, 8)), Vector2(50, 20));
        expect(component.positionOf(Vector2(0, 0)), Vector2(44, 12));
      });

      test('center flips', () {
        final component = PositionComponent()
          ..size = Vector2(10, 10)
          ..position = Vector2(50, 20)
          ..anchor = const Anchor(0.6, 0.8);

        expect(component.positionOf(Vector2(6, 8)), Vector2(50, 20));
        expect(component.positionOf(Vector2(0, 0)), Vector2(44, 12));
        expect(component.positionOf(Vector2(10, 0)), Vector2(54, 12));
        component.flipHorizontallyAroundCenter();
        expect(component.positionOf(Vector2(6, 8)), Vector2(48, 20));
        expect(component.positionOf(Vector2(0, 0)), Vector2(54, 12));
        expect(component.positionOf(Vector2(10, 0)), Vector2(44, 12));
        component.flipVerticallyAroundCenter();
        expect(component.positionOf(Vector2(6, 8)), Vector2(48, 14));
        expect(component.positionOf(Vector2(0, 0)), Vector2(54, 22));
        expect(component.positionOf(Vector2(10, 0)), Vector2(44, 22));
      });

      test('double center flips', () {
        final startPosition = Vector2(50, 20);
        final component = PositionComponent()
          ..size = Vector2(10, 20)
          ..angle = 2
          ..scale = Vector2(2.0, 3.0)
          ..position = startPosition;
        final centerPosition = component.center;

        component.flipVerticallyAroundCenter();
        // Same position after one vertical flip.
        expect(component.center, closeToVector(centerPosition, 1e-14));

        component.flipVerticallyAroundCenter();
        // Same position after flipping back the vertical flip.
        expect(component.center, closeToVector(centerPosition, 1e-14));

        component.flipHorizontallyAroundCenter();
        // Same position after one horizontal flip.
        expect(component.center, closeToVector(centerPosition, 1e-14));

        component.flipHorizontallyAroundCenter();
        // Same position after flipping back the horizontal flip.
        expect(component.center, closeToVector(centerPosition, 1e-14));

        component.flipVerticallyAroundCenter();
        component.flipHorizontallyAroundCenter();
        // Same position after flipping both vertically and horizontally.
        expect(component.center, closeToVector(centerPosition, 1e-14));

        component.flipVerticallyAroundCenter();
        component.flipHorizontallyAroundCenter();
        // Same position after flipping back both vertically and horizontally.
        expect(component.center, closeToVector(centerPosition, 1e-14));

        component.flipHorizontallyAroundCenter();
        component.flipVerticallyAroundCenter();
        // Same position after flipping both horizontally and vertically.
        expect(component.center, closeToVector(centerPosition, 1e-14));

        component.flipVerticallyAroundCenter();
        component.flipHorizontallyAroundCenter();
        // Same position after flipping back both horizontally and vertically in
        // the reverse order.
        expect(component.center, closeToVector(centerPosition, 1e-14));
      });

      test('isHorizontallyFlipped', () {
        final component = PositionComponent()
          ..size = Vector2(10, 10)
          ..position = Vector2(50, 20)
          ..anchor = const Anchor(0.6, 0.8);

        expect(component.isFlippedHorizontally, isFalse);
        component.flipHorizontally();
        expect(component.isFlippedHorizontally, isTrue);
        component.flipHorizontally();
        expect(component.isFlippedHorizontally, isFalse);
        component.flipHorizontallyAroundCenter();
        expect(component.isFlippedHorizontally, isTrue);
        component.flipHorizontallyAroundCenter();
        expect(component.isFlippedHorizontally, isFalse);
      });

      test('isVerticallyFlipped', () {
        final component = PositionComponent()
          ..size = Vector2(10, 10)
          ..position = Vector2(50, 20)
          ..anchor = const Anchor(0.6, 0.8);

        expect(component.isFlippedVertically, isFalse);
        component.flipVertically();
        expect(component.isFlippedVertically, isTrue);
        component.flipVertically();
        expect(component.isFlippedVertically, isFalse);
        component.flipVerticallyAroundCenter();
        expect(component.isFlippedVertically, isTrue);
        component.flipVerticallyAroundCenter();
        expect(component.isFlippedVertically, isFalse);
      });

      test('rotations', () {
        final component = PositionComponent()
          ..size = Vector2(8, 6)
          ..position = Vector2(50, 20)
          ..anchor = Anchor.center;

        // Rotate the component in small increments counterclockwise
        // and track the coordinate of its top-right corner
        for (var i = 0; i < 30; i++) {
          component.angle = -i / 10;
          final cosA = cos(i / 10);
          final sinA = sin(i / 10);
          // The component's diagonal is 10, so it's radius (distance from the
          // center to any vertex) is 5. If we denote φ the angle that the
          // diagonal makes with a bimedian, then the cosine of that angle is
          // 0.8 and the sine is 0.6. Thus, when the whole rectangle is rotated
          // by angle A = i/10, the coordinates of any vertex can be computed
          // from the trigonometric formulas for `sin(φ + A)` and `cos(φ + A)`,
          // scaled by the radius of the rectangle.
          final expectedX = 50 + 5 * (0.8 * cosA - 0.6 * sinA);
          final expectedY = 20 - 5 * (0.6 * cosA + 0.8 * sinA);
          final topRight = component.positionOf(Vector2(8, 0));
          expect(topRight.x, closeTo(expectedX, 1e-13));
          expect(topRight.y, closeTo(expectedY, 1e-13));
        }
      });

      testRandom('random local<->global', (Random rnd) {
        final parent = PositionComponent()..size = Vector2(50, 25);
        final child = PositionComponent()
          ..size = Vector2(10, 8)
          ..position = Vector2(50, 20)
          ..anchor = const Anchor(0.1, 0.2);
        parent.add(child);

        for (var i = 0; i < 100; i++) {
          child.angle = (rnd.nextDouble() - 0.5) * 10;
          child.x = rnd.nextDouble() * 100;
          child.y = rnd.nextDouble() * 70 + 30;
          parent.angle = (rnd.nextDouble() - 0.5) * 5;
          parent.x = rnd.nextDouble() * 300;
          parent.y = rnd.nextDouble() * 1000;
          if (rnd.nextBool()) {
            child.flipHorizontally();
          }
          if (rnd.nextBool()) {
            child.flipVertically();
          }
          if (rnd.nextDouble() < 0.1) {
            parent.flipHorizontally();
          }

          final globalX = (rnd.nextDouble() - 0.3) * 200;
          final globalY = (rnd.nextDouble() - 0.1) * 200;
          final localPoint = child.absoluteToLocal(Vector2(globalX, globalY));
          final globalPoint = child.absolutePositionOf(localPoint);
          expect(globalPoint.x, closeTo(globalX, 1e-10));
          expect(globalPoint.y, closeTo(globalY, 1e-10));
        }
      });

      testRandom('transform matrix', (Random rnd) {
        final component = PositionComponent()
          ..size = Vector2(5, 10)
          ..anchor = Anchor.center;

        for (var i = 0; i < 10; i++) {
          final x = rnd.nextDouble() * 100;
          final y = rnd.nextDouble() * 70 + 30;
          final angle = (rnd.nextDouble() - 0.5) * 10;
          component.x = x;
          component.y = y;
          component.angle = angle;

          final transform = Matrix4.identity()
            ..translate(x, y)
            ..rotateZ(angle)
            ..translate(
              -component.anchor.x * component.width,
              -component.anchor.y * component.height,
            );
          for (var j = 0; j < 16; j++) {
            expect(component.transformMatrix[j], closeTo(transform[j], 1e-13));
          }
        }
      });

      test('change anchor', () {
        final component = PositionComponent()
          ..size = Vector2(10, 10)
          ..position = Vector2(100, 100)
          ..anchor = Anchor.center;

        expect(component.toLocal(Vector2(100, 100)), Vector2(5, 5));
        component.anchor = Anchor.topLeft;
        expect(component.toLocal(Vector2(100, 100)), Vector2(0, 0));
        component.anchor = Anchor.topRight;
        expect(component.toLocal(Vector2(100, 100)), Vector2(10, 0));
        component.anchor = Anchor.bottomLeft;
        expect(component.toLocal(Vector2(100, 100)), Vector2(0, 10));
        component.anchor = Anchor.bottomRight;
        expect(component.toLocal(Vector2(100, 100)), Vector2(10, 10));
        component.anchor = const Anchor(0.1, 0.2);
        expect(component.toLocal(Vector2(100, 100)), Vector2(1, 2));
      });

      test('distance', () {
        final parent = PositionComponent(size: Vector2.all(100));
        final comp1 = PositionComponent(position: Vector2(10, 20));
        final comp2 = PositionComponent(position: Vector2(40, 60));
        parent.add(comp1);
        parent.add(comp2);

        // The distance is the same in both directions
        expect(comp1.distance(comp2), 50);
        expect(comp2.distance(comp1), 50);

        // Rotations/rescaling should not affect the distance
        comp1.angle = 1;
        comp2.angle = -0.5;
        comp1.scale = Vector2(2, 1.1);
        comp2.flipVertically();
        expect(comp1.distance(comp2), 50);

        // The distance is not affected by parent's rescaling
        parent.scale = Vector2.all(10);
        expect(comp1.distance(comp2), 50);
      });

      test('deep nested', () async {
        final game = FlameGame()..onGameResize(Vector2.all(100));
        final c1 = PositionComponent()..position = Vector2(10, 20);
        final c2 = Component();
        final c3 = PositionComponent()..position = Vector2(-1, -1);
        final c4 = Component();
        final c5 = PositionComponent()..position = Vector2(5, 0);
        c1.add(c2);
        c2.add(c3);
        c3.add(c4);
        c4.add(c5);
        game.add(c1);
        await game.ready();
        // Verify that the absolute coordinate is computed correctly even
        // if the component is part of a nested tree where not all of
        // the components are [PositionComponent]s.
        expect(c5.absoluteToLocal(Vector2(14, 19)), Vector2.zero());
      });

      test('auxiliary getters/setters', () async {
        final game = FlameGame()..onGameResize(Vector2.all(100));
        final parent = PositionComponent(position: Vector2(12, 19));
        final child =
            PositionComponent(position: Vector2(11, -1), size: Vector2(4, 6));
        parent.add(child);
        game.add(parent);
        await game.ready();

        expect(child.anchor, Anchor.topLeft);
        expect(child.topLeftPosition, Vector2(11, -1));
        expect(child.absoluteTopLeftPosition, Vector2(23, 18));
        expect(child.center, Vector2(13, 2));
        expect(child.absoluteCenter, Vector2(25, 21));
        expect(child.position, Vector2(11, -1));
        expect(child.absolutePosition, Vector2(23, 18));

        child.center = Vector2(5, 5);
        expect(child.center, Vector2(5, 5));
        expect(child.position, Vector2(3, 2));
        expect(child.absolutePosition, Vector2(15, 21));
      });

      test('lookAt', () {
        final component = PositionComponent();

        final targets = [
          Vector2(0, 1),
          Vector2.all(2),
          Vector2(-1, 0),
          Vector2.all(-50)
        ];
        final expectedAngles = [pi, (3 * pi / 4), (-pi / 2), (-pi / 4)];

        for (var i = 0; i < targets.length; ++i) {
          final target = targets.elementAt(i);
          final angle = expectedAngles.elementAt(i);

          expectDouble(
            component.angleTo(target),
            angle - component.angle,
            epsilon: 1e-10,
          );

          component.lookAt(target);
          expectDouble(component.angle, angle, epsilon: 1e-10);
        }
      });

      test('lookAt with native angle', () {
        final component = PositionComponent(nativeAngle: pi / 2);

        final targets = [
          Vector2(0, 1),
          Vector2.all(2),
          Vector2(-1, 0),
          Vector2.all(-50)
        ];
        final expectedAngles = [pi / 2, (pi / 4), -pi, (-3 * pi / 4)];

        for (var i = 0; i < targets.length; ++i) {
          final target = targets.elementAt(i);
          final angle = expectedAngles.elementAt(i);

          expectDouble(
            component.angleTo(target),
            angle - component.angle,
            epsilon: 1e-10,
          );

          component.lookAt(target);
          expectDouble(component.angle, angle, epsilon: 1e-10);
        }
      });

      test('lookAt with nested components', () {
        late PositionComponent component;

        PositionComponent(
          angle: pi / 2,
          children: [
            PositionComponent(
              angle: pi / 2,
              children: [
                component = PositionComponent(
                  nativeAngle: -pi,
                )
              ],
            )
          ],
        );

        final targets = [
          Vector2(0, 1),
          Vector2.all(2),
          Vector2(-1, 0),
          Vector2.all(-50)
        ];
        final expectedAngles = [pi, (3 * pi / 4), -pi / 2, (-pi / 4)];

        for (var i = 0; i < targets.length; ++i) {
          final target = targets.elementAt(i);
          final angle = expectedAngles.elementAt(i);

          expectDouble(
            component.angleTo(target),
            angle - component.angle,
            epsilon: 1e-10,
          );

          component.lookAt(target);
          expectDouble(component.angle, angle, epsilon: 1e-10);
        }
      });

      test('lookAt corner cases', () {
        final component = PositionComponent(position: Vector2(-20, 50));
        component.lookAt(component.absolutePosition);
        expectDouble(component.angle, 0, epsilon: 1e-10);

        component.nativeAngle = 3 * pi / 2;
        component.lookAt(component.absolutePosition);
        expectDouble(component.angle, -component.nativeAngle, epsilon: 1e-10);
      });
    });

    group('Rendering', () {
      test('render in debug mode', () {
        final component = _MyDebugComponent()
          ..position = Vector2(23, 17)
          ..size = Vector2.all(10);
        final canvas = MockCanvas();
        component.renderTree(canvas);
        expect(
          canvas,
          MockCanvas()
            ..translate(23, 17)
            ..drawRect(const Rect.fromLTWH(0, 0, 10, 10))
            ..drawLine(const Offset(0, -2), const Offset(0, 2))
            ..drawLine(const Offset(-2, 0), const Offset(2, 0))
            ..drawParagraph(null, const Offset(-30, -15))
            ..drawParagraph(null, const Offset(-20, 10))
            ..translate(0, 0), // canvas.restore
        );
      });

      test('render without coordinates', () {
        final component = _MyDebugComponent()
          ..position = Vector2(23, 17)
          ..size = Vector2.all(10)
          ..anchor = Anchor.center
          ..precision = null;
        final canvas = MockCanvas();
        component.renderTree(canvas);
        expect(
          canvas,
          MockCanvas()
            ..translate(18, 12)
            ..drawRect(const Rect.fromLTWH(0, 0, 10, 10))
            ..drawLine(const Offset(5, 3), const Offset(5, 7))
            ..drawLine(const Offset(3, 5), const Offset(7, 5))
            ..translate(0, 0), // canvas.restore
        );
      });
    });

    group('Bounding rectangle', () {
      test('Scale/flip', () {
        final component = PositionComponent(
          position: Vector2(5, 5),
          size: Vector2(4, 2),
          anchor: Anchor.center,
        );
        expect(component.toRect(), const Rect.fromLTWH(3, 4, 4, 2));
        component.scale = Vector2(0.5, 1);
        expect(component.toRect(), const Rect.fromLTWH(4, 4, 2, 2));
        component.flipHorizontally();
        expect(component.toRect(), const Rect.fromLTWH(4, 4, 2, 2));
        component.flipVertically();
        expect(component.toRect(), const Rect.fromLTWH(4, 4, 2, 2));
      });

      test('flip with non-central anchor', () {
        final component = PositionComponent(
          position: Vector2(0, 0),
          size: Vector2(4, 2),
        );
        expect(component.toRect(), const Rect.fromLTWH(0, 0, 4, 2));
        component.flipHorizontally();
        expect(component.toRect(), const Rect.fromLTWH(-4, 0, 4, 2));
        component.flipVertically();
        expect(component.toRect(), const Rect.fromLTWH(-4, -2, 4, 2));
      });

      test('rotated component', () {
        const w = 5.0;
        const h = 2.0;
        final component = PositionComponent(size: Vector2(w, h));
        for (var i = 0; i < 10; i++) {
          final a = (i / 10) * Transform2D.tau / 4;
          component.angle = a;
          expect(
            component.toRect(),
            Rect.fromLTRB(
              -h * sin(a),
              0,
              w * cos(a),
              w * sin(a) + h * cos(a),
            ),
          );
        }
      });

      test('absolute toRect', () async {
        final game = FlameGame()..onGameResize(Vector2.all(100));
        final parent = PositionComponent(
          position: Vector2(10, 10),
          size: Vector2(6, 6),
        );
        final child = PositionComponent(
          position: Vector2(-3, 3),
          size: Vector2(1, 1),
        );
        parent.add(child);
        game.add(parent);
        await game.ready();
        expect(child.toRect(), const Rect.fromLTWH(-3, 3, 1, 1));
        expect(child.toAbsoluteRect(), const Rect.fromLTWH(7, 13, 1, 1));
      });
    });
  });
}

class _MyHitboxComponent extends PositionComponent with GestureHitboxes {}

class _MyDebugComponent extends PositionComponent {
  int? precision = 0;

  @override
  bool get debugMode => true;

  @override
  int? get debugCoordinatesPrecision => precision;
}
