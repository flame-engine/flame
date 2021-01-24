import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/src/geometry/polygon.dart';
import 'package:test/test.dart';

class MyComponent extends PositionComponent {}

class MyHitboxComponent extends PositionComponent with Hitbox {}

void main() {
  group('PositionComponent overlap test', () {
    test('overlap', () {
      final PositionComponent component = MyComponent();
      component.position = Vector2(2.0, 2.0);
      component.size = Vector2(4.0, 4.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(2.0, 2.0);
      expect(component.containsPoint(point), true);
    });

    test('overlap on edge', () {
      final PositionComponent component = MyComponent();
      component.position = Vector2(2.0, 2.0);
      component.size = Vector2(2.0, 2.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(1.0, 1.0);
      expect(component.containsPoint(point), true);
    });

    test('not overlapping with x', () {
      final PositionComponent component = MyComponent();
      component.position = Vector2(2.0, 2.0);
      component.size = Vector2(2.0, 2.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(4.0, 1.0);
      expect(component.containsPoint(point), false);
    });

    test('not overlapping with y', () {
      final PositionComponent component = MyComponent();
      component.position = Vector2(2.0, 2.0);
      component.size = Vector2(2.0, 2.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(1.0, 4.0);
      expect(component.containsPoint(point), false);
    });

    test('overlapping with angle', () {
      final PositionComponent component = MyComponent();
      component.position = Vector2(2.0, 2.0);
      component.size = Vector2(2.0, 2.0);
      component.angle = math.pi / 4;
      component.anchor = Anchor.center;

      final point = Vector2(3.1, 2.0);
      expect(component.containsPoint(point), true);
    });

    test('not overlapping with angle', () {
      final PositionComponent component = MyComponent();
      component.position = Vector2(2.0, 2.0);
      component.size = Vector2(2.0, 2.0);
      component.angle = math.pi / 4;
      component.anchor = Anchor.center;

      final point = Vector2(1.0, 0.1);
      expect(component.containsPoint(point), false);
    });

    test('overlapping with angle and topLeft anchor', () {
      final PositionComponent component = MyComponent();
      component.position = Vector2(1.0, 1.0);
      component.size = Vector2(2.0, 2.0);
      component.angle = math.pi / 4;
      component.anchor = Anchor.topLeft;

      final point = Vector2(1.0, 3.1);
      expect(component.containsPoint(point), true);
    });

    test('component with hitbox contains point', () {
      final size = Vector2(2.0, 2.0);
      final Hitbox component = MyHitboxComponent();
      component.position = Vector2(1.0, 1.0);
      component.anchor = Anchor.topLeft;
      component.size = size;
      final hitbox = HitboxPolygon([
        Vector2(1, 0),
        Vector2(0, -1),
        Vector2(-1, 0),
        Vector2(0, 1),
      ]);
      component.addShape(hitbox);

      final point = component.position + component.size / 4;
      expect(component.containsPoint(point), true);
    });

    test('component with hitbox does not contains point', () {
      final size = Vector2(2.0, 2.0);
      final Hitbox component = MyHitboxComponent();
      component.position = Vector2(1.0, 1.0);
      component.anchor = Anchor.topLeft;
      component.size = size;
      component.addShape(HitboxPolygon([
        Vector2(1, 0),
        Vector2(0, -1),
        Vector2(-1, 0),
        Vector2(0, 1),
      ]));

      final point = Vector2(1.1, 1.1);
      expect(component.containsPoint(point), false);
    });
  });
}
