import 'dart:math' as math;

import 'package:flame/anchor.dart';
import 'package:flame/components/position_component.dart';
import 'package:flame/extensions/vector2.dart';
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
      expect(component.checkOverlap(point), true);
    });

    test('overlap on edge', () {
      final PositionComponent component = MyComponent();
      component.position = Vector2(2.0, 2.0);
      component.size = Vector2(2.0, 2.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(1.0, 1.0);
      expect(component.checkOverlap(point), true);
    });

    test('not overlapping with x', () {
      final PositionComponent component = MyComponent();
      component.position = Vector2(2.0, 2.0);
      component.size = Vector2(2.0, 2.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(4.0, 1.0);
      expect(component.checkOverlap(point), false);
    });

    test('not overlapping with y', () {
      final PositionComponent component = MyComponent();
      component.position = Vector2(2.0, 2.0);
      component.size = Vector2(2.0, 2.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(1.0, 4.0);
      expect(component.checkOverlap(point), false);
    });

    test('overlapping with angle', () {
      final PositionComponent component = MyComponent();
      component.position = Vector2(2.0, 2.0);
      component.size = Vector2(2.0, 2.0);
      component.angle = math.pi / 4;
      component.anchor = Anchor.center;

      final point = Vector2(3.1, 2.0);
      expect(component.checkOverlap(point), true);
    });

    test('not overlapping with angle', () {
      final PositionComponent component = MyComponent();
      component.position = Vector2(2.0, 2.0);
      component.size = Vector2(2.0, 2.0);
      component.angle = math.pi / 4;
      component.anchor = Anchor.center;

      final point = Vector2(1.0, 0.1);
      expect(component.checkOverlap(point), false);
    });

    test('overlapping with angle and topLeft anchor', () {
      final PositionComponent component = MyComponent();
      component.position = Vector2(1.0, 1.0);
      component.size = Vector2(2.0, 2.0);
      component.angle = math.pi / 4;
      component.anchor = Anchor.topLeft;

      final point = Vector2(1.0, 3.1);
      expect(component.checkOverlap(point), true);
    });
  });
}
