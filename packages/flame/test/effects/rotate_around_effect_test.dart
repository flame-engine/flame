import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/geometry.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

const _epsilon = 1e-13;

void main() {
  group('RotateAroundEffect', () {
    testWithFlameGame('applies rotation correctly', (game) async {
      final component = PositionComponent(position: Vector2(50, 0));
      await game.ensureAdd(component);

      final effect = RotateAroundEffect(
        tau,
        center: Vector2(50, 50),
        EffectController(duration: 1),
      );
      component.add(effect);

      game.update(0);
      expect(component.angle, 0);
      expect(component.position, Vector2(50, 0));

      game.update(0.5);
      expect(component.angle, closeTo(pi, _epsilon));
      expect(component.position, closeToVector(Vector2(50, 100), _epsilon));

      game.update(0.5);
      expect(component.angle % tau, closeTo(0, _epsilon));
      expect(component.position, closeToVector(Vector2(50, 0), _epsilon));
    });

    testWithFlameGame('aligns rotation correctly', (game) async {
      final component = PositionComponent(position: Vector2(100, 100));
      await game.ensureAdd(component);

      final effect = RotateAroundEffect(
        pi,
        center: Vector2(50, 50),
        EffectController(duration: 1),
      );
      component.add(effect);

      game.update(0);
      expect(component.angle, 0);
      expect(component.position, Vector2(100, 100));

      game.update(0.5);
      expect(component.angle, closeTo(pi / 2, _epsilon));
      expect(component.position, closeToVector(Vector2(0, 100), _epsilon));

      game.update(0.5);
      expect(component.angle, closeTo(pi, _epsilon));
      expect(component.position, closeToVector(Vector2(0, 0), _epsilon));
    });

    testWithFlameGame('handles infinite rotation', (game) async {
      final component = PositionComponent(position: Vector2(100, 100));
      await game.ensureAdd(component);

      final effect = RotateAroundEffect(
        tau,
        center: Vector2(50, 50),
        EffectController(duration: 1, infinite: true),
      );
      component.add(effect);

      for (var i = 0; i < 10; i++) {
        game.update(0.5);
        expect(component.angle % tau, closeTo(i.isOdd ? 0 : pi, _epsilon));
        expect(
          component.position,
          closeToVector(Vector2.all(i.isOdd ? 100 : 0), _epsilon),
        );
      }
    });
  });
}
