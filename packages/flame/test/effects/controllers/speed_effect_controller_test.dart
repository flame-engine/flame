import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpeedEffectController', () {
    group('properties', () {
      test('simple properties', () {
        final ec = SpeedEffectController(LinearEffectController(1), speed: 10);
        expect(ec.duration, isNaN);
        expect(ec.progress, 0);
        expect(ec.isRandom, true);
        expect(ec.started, true);
        expect(ec.completed, false);
      });

      test('assert speed positive', () {
        expect(
          () => SpeedEffectController(LinearEffectController(1), speed: 0),
          failsAssert('Speed must be positive: 0.0'),
        );
        expect(
          () => SpeedEffectController(LinearEffectController(1), speed: -1),
          failsAssert('Speed must be positive: -1.0'),
        );
      });

      test('assert effect measurable', () {
        expect(
          () => SizeEffect.by(
            Vector2.zero(),
            SpeedEffectController(LinearEffectController(1), speed: 1),
          ),
          failsAssert(
            'SpeedEffectController can only be applied to a MeasurableEffect',
          ),
        );
      });
    });

    group('applied to various effects', () {
      testWithFlameGame('speed on MoveEffect', (game) async {
        final effect = MoveEffect.to(
          Vector2(8, 12),
          EffectController(speed: 1),
        );
        final component = PositionComponent(position: Vector2(5, 8));
        component.add(effect);
        await game.ensureAdd(component);
        game.update(0);

        expect(effect.controller.duration, 5);
        game.update(5);
        expect(component.position, closeToVector(Vector2(8, 12)));
      });

      testWithFlameGame('speed on MoveEffect with delay', (game) async {
        final effect = MoveToEffect(
          Vector2(8, 12),
          EffectController(speed: 1, startDelay: 1),
        );
        final component = PositionComponent(position: Vector2(5, 8));
        component.add(effect);
        await game.ensureAdd(component);
        expect(effect.controller.duration, 6);
        game.update(1);
        expect(component.position, closeToVector(Vector2(5, 8)));
        game.update(5);
        expect(component.position, closeToVector(Vector2(8, 12)));
      });

      testWithFlameGame('speed on MoveAlongPathEffect', (game) async {
        final effect = MoveAlongPathEffect(
          Path()
            ..lineTo(30, 40)
            ..lineTo(30, 20)
            ..lineTo(10, 35)
            ..lineTo(10, 30),
          EffectController(speed: 4),
          absolute: true,
        );
        final component = PositionComponent(position: Vector2(5, 8));
        component.add(effect);
        await game.ensureAdd(component);
        game.update(0);

        expect(effect.controller.duration, 25);
        game.update(25);
        expect(component.position, closeToVector(Vector2(10, 30)));
      });

      testWithFlameGame('speed on RotateEffect', (game) async {
        final effect = RotateEffect.to(tau, EffectController(speed: 1));
        final component = PositionComponent(position: Vector2(5, 8));
        component.add(effect);
        await game.ensureAdd(component);
        game.update(0);

        expect(effect.controller.duration, tau);
        game.update(tau);
        expect(component.angle, closeTo(tau.toNormalizedAngle(), 1e-15));
      });

      testWithFlameGame('reset', (game) async {
        final effect = MoveEffect.to(
          Vector2(10, 0),
          SpeedEffectController(LinearEffectController(0), speed: 1),
        );
        final component = PositionComponent();
        component.add(effect..removeOnFinish = false);
        await game.ensureAdd(component);
        game.update(0);

        game.update(0);
        expect(effect.controller.duration, 10);
        game.update(10);
        expect(effect.controller.completed, true);

        expect(component.position, closeToVector(Vector2(10, 0)));
        component.position = Vector2.all(40);
        effect.reset();
        game.update(0);
        expect(effect.controller.duration, 50);
      });
    });
  });
}
