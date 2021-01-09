import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:test/test.dart';

class MyComponent extends PositionComponent {}

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

    test('component with hull contains point', () {
      final size = Vector2(2.0, 2.0);
      final PositionComponent component = MyComponent();
      component.position = Vector2(1.0, 1.0);
      component.anchor = Anchor.topLeft;
      component.size = size;
      component.hull = [
        Vector2(size.x/2, 0),
        Vector2(0, -size.y/2),
        Vector2(-size.x/2, 0),
        Vector2(0, size.y/2),
      ];

      final point = component.position + component.size / 4;
      expect(component.containsPoint(point), true);
    });

    test('component with hull does not contains point', () {
      final size = Vector2(2.0, 2.0);
      final PositionComponent component = MyComponent();
      component.position = Vector2(1.0, 1.0);
      component.anchor = Anchor.topLeft;
      component.size = size;
      component.hull = [
        Vector2(size.x/2, 0),
        Vector2(0, -size.y/2),
        Vector2(-size.x/2, 0),
        Vector2(0, size.y/2),
      ];

      final point = Vector2(1.1, 1.1);
      expect(component.containsPoint(point), false);
    });
  });
}
