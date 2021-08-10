import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:test/test.dart';

class MyComponent extends PositionComponent {}

class MyHitboxComponent extends PositionComponent with Hitbox {}

void main() {
  group('PositionComponent overlap test', () {
    test('overlap', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(4.0, 4.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(2.0, 2.0);
      expect(component.containsPoint(point), true);
    });

    test('overlap on edge', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(2.0, 2.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(1.0, 1.0);
      expect(component.containsPoint(point), true);
    });

    test('not overlapping with x', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(2.0, 2.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(4.0, 1.0);
      expect(component.containsPoint(point), false);
    });

    test('not overlapping with y', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(2.0, 2.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(1.0, 4.0);
      expect(component.containsPoint(point), false);
    });

    test('overlapping with angle', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(2.0, 2.0);
      component.angle = math.pi / 4;
      component.anchor = Anchor.center;

      final point = Vector2(3.1, 2.0);
      expect(component.containsPoint(point), true);
    });

    test('not overlapping with angle', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(2.0, 2.0);
      component.angle = math.pi / 4;
      component.anchor = Anchor.center;

      final point = Vector2(1.0, 0.1);
      expect(component.containsPoint(point), false);
    });

    test('overlapping with angle and topLeft anchor', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(1.0, 1.0);
      component.size.setValues(2.0, 2.0);
      component.angle = math.pi / 4;
      component.anchor = Anchor.topLeft;

      final point = Vector2(1.0, 3.1);
      expect(component.containsPoint(point), true);
    });

    test('component with hitbox contains point', () {
      final Hitbox component = MyHitboxComponent();
      component.position.setValues(1.0, 1.0);
      component.anchor = Anchor.topLeft;
      component.size.setValues(2.0, 2.0);
      final hitbox = HitboxPolygon([
        Vector2(1, 0),
        Vector2(0, -1),
        Vector2(-1, 0),
        Vector2(0, 1),
      ]);
      component.addHitbox(hitbox);

      final point = component.position + component.size / 4;
      expect(component.containsPoint(point), true);
    });

    test('component with anchor topLeft contains point on edge', () {
      final Hitbox component = MyHitboxComponent();
      component.position.setValues(-1, -1);
      component.anchor = Anchor.topLeft;
      component.size.setValues(2.0, 2.0);
      final hitbox = HitboxRectangle();
      component.addHitbox(hitbox);

      expect(component.containsPoint(Vector2(1, 1)), true);
      expect(component.containsPoint(Vector2(1, -1)), true);
      expect(component.containsPoint(Vector2(-1, -1)), true);
      expect(component.containsPoint(Vector2(-1, 1)), true);
    });

    test('component with anchor bottomRight contains point on edge', () {
      final Hitbox component = MyHitboxComponent();
      component.position.setValues(1, 1);
      component.anchor = Anchor.bottomRight;
      component.size.setValues(2.0, 2.0);
      final hitbox = HitboxRectangle();
      component.addHitbox(hitbox);

      expect(component.containsPoint(Vector2(1, 1)), true);
      expect(component.containsPoint(Vector2(1, -1)), true);
      expect(component.containsPoint(Vector2(-1, -1)), true);
      expect(component.containsPoint(Vector2(-1, 1)), true);
    });

    test('component with anchor topRight does not contain close points', () {
      final Hitbox component = MyHitboxComponent();
      component.position.setValues(1, 1);
      component.anchor = Anchor.topLeft;
      component.size.setValues(2.0, 2.0);
      final hitbox = HitboxRectangle();
      component.addHitbox(hitbox);

      expect(component.containsPoint(Vector2(0.0, 0.0)), false);
      expect(component.containsPoint(Vector2(0.9, 0.9)), false);
      expect(component.containsPoint(Vector2(3.1, 3.1)), false);
      expect(component.containsPoint(Vector2(1.1, 3.1)), false);
    });

    test('component with hitbox does not contains point', () {
      final Hitbox component = MyHitboxComponent();
      component.position.setValues(1.0, 1.0);
      component.anchor = Anchor.topLeft;
      component.size.setValues(2.0, 2.0);
      component.addHitbox(HitboxPolygon([
        Vector2(1, 0),
        Vector2(0, -1),
        Vector2(-1, 0),
        Vector2(0, 1),
      ]));

      final point = Vector2(1.1, 1.1);
      expect(component.containsPoint(point), false);
    });

    test('component with zero size does not contain point', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(0.0, 0.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(2.0, 2.0);
      expect(component.containsPoint(point), false);
    });

    test('component with zero size does not contain point', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(0.0, 0.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(2.0, 2.0);
      expect(component.containsPoint(point), false);
    });

    test('component with anchor center has the same center and position', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 1.0);
      component.size.setValues(3.0, 1.0);
      component.angle = 2.0;
      component.anchor = Anchor.center;

      expect(component.center, component.position);
      expect(component.absoluteCenter, component.position);
      expect(
        component.topLeftPosition,
        component.position - component.size / 2,
      );
    });

    test('component with anchor topLeft has the correct center', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 1.0);
      component.size.setValues(3.0, 1.0);
      component.angle = 0.0;
      component.anchor = Anchor.topLeft;

      expect(component.center, component.position + component.size / 2);
      expect(component.absoluteCenter, component.position + component.size / 2);
    });

    test('component with parent has the correct center', () {
      final parent = MyComponent();
      parent.position.setValues(2.0, 1.0);
      parent.anchor = Anchor.topLeft;
      final child = MyComponent();
      child.position.setValues(2.0, 1.0);
      child.size.setValues(3.0, 1.0);
      child.angle = 0.0;
      child.anchor = Anchor.topLeft;
      parent.addChild(child);

      expect(child.absoluteTopLeftPosition, child.position + parent.position);
      expect(
        child.absoluteTopLeftPosition,
        child.topLeftPosition + parent.topLeftPosition,
      );
      expect(child.absoluteCenter, parent.position + child.center);
    });

    test('scaled component contains point', () {
      final component = MyComponent();
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
          component.containsPoint(topRightPoint
            ..x += epsilon.x
            ..y -= epsilon.y),
          topRightResult ?? expectedResult,
        );
        expect(
          component.containsPoint(bottomLeftPoint
            ..x -= epsilon.x
            ..y += epsilon.y),
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

  group('coordinates transforms test', () {
    test('local<->parent transforms', () {
      final component = MyComponent()
        ..size = Vector2(10, 10)
        ..position = Vector2(50, 20)
        ..anchor = Anchor.center;

      expect(component.localToParent(Vector2(0, 0)), Vector2(45, 15));
      expect(component.localToParent(Vector2(5, 5)), Vector2(50, 20));
      expect(component.localToParent(Vector2(10, 0)), Vector2(55, 15));
      expect(component.localToParent(Vector2(0, 10)), Vector2(45, 25));

      expect(component.parentToLocal(Vector2(0, 0)), Vector2(-45, -15));
      expect(component.parentToLocal(Vector2(50, 20)), Vector2(5, 5));
      expect(component.parentToLocal(Vector2(55, 25)), Vector2(10, 10));
      expect(component.parentToLocal(Vector2(100, 100)), Vector2(55, 85));
    });

    test('flips', () {
      final component = MyComponent()
        ..size = Vector2(10, 10)
        ..position = Vector2(50, 20)
        ..anchor = const Anchor(0.6, 0.8);

      expect(component.localToParent(Vector2(6, 8)), Vector2(50, 20));
      expect(component.localToParent(Vector2(0, 0)), Vector2(44, 12));
      component.flipHorizontally();
      expect(component.localToParent(Vector2(6, 8)), Vector2(50, 20));
      expect(component.localToParent(Vector2(0, 0)), Vector2(56, 12));
      component.flipVertically();
      expect(component.localToParent(Vector2(6, 8)), Vector2(50, 20));
      expect(component.localToParent(Vector2(0, 0)), Vector2(56, 28));
      component.flipHorizontally();
      expect(component.localToParent(Vector2(6, 8)), Vector2(50, 20));
      expect(component.localToParent(Vector2(0, 0)), Vector2(44, 28));
      component.flipVertically();
      expect(component.localToParent(Vector2(6, 8)), Vector2(50, 20));
      expect(component.localToParent(Vector2(0, 0)), Vector2(44, 12));
    });

    test('center flips', () {
      final component = MyComponent()
        ..size = Vector2(10, 10)
        ..position = Vector2(50, 20)
        ..anchor = const Anchor(0.6, 0.8);

      expect(component.localToParent(Vector2(6, 8)), Vector2(50, 20));
      expect(component.localToParent(Vector2(0, 0)), Vector2(44, 12));
      expect(component.localToParent(Vector2(10, 0)), Vector2(54, 12));
      component.flipHorizontallyAroundCenter();
      expect(component.localToParent(Vector2(6, 8)), Vector2(48, 20));
      expect(component.localToParent(Vector2(0, 0)), Vector2(54, 12));
      expect(component.localToParent(Vector2(10, 0)), Vector2(44, 12));
      component.flipVerticallyAroundCenter();
      expect(component.localToParent(Vector2(6, 8)), Vector2(48, 14));
      expect(component.localToParent(Vector2(0, 0)), Vector2(54, 22));
      expect(component.localToParent(Vector2(10, 0)), Vector2(44, 22));
    });

    test('rotations', () {
      final component = MyComponent()
        ..size = Vector2(8, 6)
        ..position = Vector2(50, 20)
        ..anchor = Anchor.center;

      // Rotate the component in small increments counterclockwise
      // and track the coordinate of its top-right corner
      for (var i = 0; i < 30; i++) {
        component.angle = -i / 10;
        final cosA = math.cos(i / 10);
        final sinA = math.sin(i / 10);
        final expectedX = 50 + 5 * (0.8 * cosA - 0.6 * sinA);
        final expectedY = 20 - 5 * (0.6 * cosA + 0.8 * sinA);
        final topRight = component.localToParent(Vector2(8, 0));
        expect(topRight.x, closeTo(expectedX, 1e-10));
        expect(topRight.y, closeTo(expectedY, 1e-10));
      }
    });

    test('random local<->global', () {
      final parent = MyComponent()..size = Vector2(50, 25);
      final child = MyComponent()
        ..size = Vector2(10, 8)
        ..position = Vector2(50, 20)
        ..anchor = const Anchor(0.1, 0.2);
      parent.addChild(child);

      final rnd = math.Random();
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
        final globalPoint = child.localToAbsolute(localPoint);
        expect(globalPoint.x, closeTo(globalX, 1e-10));
        expect(globalPoint.y, closeTo(globalY, 1e-10));
      }
    });

    test('transform matrix', () {
      final component = MyComponent()
        ..size = Vector2(5, 10)
        ..anchor = Anchor.center;

      final rnd = math.Random();
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
          expect(component.transformMatrix[j], closeTo(transform[j], 1e-10));
        }
      }
    });

    test('change anchor', () {
      final component = MyComponent()
        ..size = Vector2(10, 10)
        ..position = Vector2(100, 100)
        ..anchor = Anchor.center;

      expect(component.parentToLocal(Vector2(100, 100)), Vector2(5, 5));
      component.anchor = Anchor.topLeft;
      expect(component.parentToLocal(Vector2(100, 100)), Vector2(0, 0));
      component.anchor = Anchor.topRight;
      expect(component.parentToLocal(Vector2(100, 100)), Vector2(10, 0));
      component.anchor = Anchor.bottomLeft;
      expect(component.parentToLocal(Vector2(100, 100)), Vector2(0, 10));
      component.anchor = Anchor.bottomRight;
      expect(component.parentToLocal(Vector2(100, 100)), Vector2(10, 10));
      component.anchor = const Anchor(0.1, 0.2);
      expect(component.parentToLocal(Vector2(100, 100)), Vector2(1, 2));
    });
  });
}
