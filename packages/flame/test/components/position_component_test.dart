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
  });
}
