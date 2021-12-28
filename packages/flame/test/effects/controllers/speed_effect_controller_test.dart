import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/src/effects/measurable_effect.dart';
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

      test('negative measure', () {
        expect(
          () async {
            final effect = BadEffect(
              SpeedEffectController(LinearEffectController(1), speed: 1),
            );
            final game = FlameGame()..onGameResize(Vector2.all(100));
            await game.ensureAdd(PositionComponent()..add(effect));
            game.update(0);
          },
          failsAssert('negative measure returned by BadEffect: -1.0'),
        );
      });
    });

    group('applied to various effects', () {
      test('speed on MoveEffect', () async {
        final effect =
            MoveEffect.to(Vector2(8, 12), EffectController(speed: 1));
        final game = FlameGame()..onGameResize(Vector2.all(100));
        final component = PositionComponent(position: Vector2(5, 8));
        component.add(effect);
        await game.ensureAdd(component);
        game.update(0);

        expect(effect.controller.duration, 5);
        game.update(5);
        expect(component.position, closeToVector(8, 12));
      });

      test('speed on MoveAlongPathEffect', () async {
        final effect = MoveAlongPathEffect(
          Path()
            ..lineTo(30, 40)
            ..lineTo(30, 20)
            ..lineTo(10, 35)
            ..lineTo(10, 30),
          EffectController(speed: 4),
          absolute: true,
        );
        final game = FlameGame()..onGameResize(Vector2.all(100));
        final component = PositionComponent(position: Vector2(5, 8));
        component.add(effect);
        await game.ensureAdd(component);
        game.update(0);

        expect(effect.controller.duration, 25);
        game.update(25);
        expect(component.position, closeToVector(10, 30));
      });

      test('speed on RotateEffect', () async {
        const tau = Transform2D.tau;
        final effect = RotateEffect.to(tau, EffectController(speed: 1));
        final game = FlameGame()..onGameResize(Vector2.all(100));
        final component = PositionComponent(position: Vector2(5, 8));
        component.add(effect);
        await game.ensureAdd(component);
        game.update(0);

        expect(effect.controller.duration, tau);
        game.update(tau);
        expect(component.angle, closeTo(tau, 1e-15));
      });

      test('reset', () async {
        final effect = MoveEffect.to(
          Vector2(10, 0),
          SpeedEffectController(LinearEffectController(0), speed: 1),
        );
        final game = FlameGame()..onGameResize(Vector2.all(100));
        final component = PositionComponent();
        component.add(effect..removeOnFinish = false);
        await game.ensureAdd(component);
        game.update(0);

        game.update(0);
        expect(effect.controller.duration, 10);
        game.update(10);
        expect(effect.controller.completed, true);

        expect(component.position, closeToVector(10, 0));
        component.position = Vector2.all(40);
        effect.reset();
        game.update(0);
        expect(effect.controller.duration, 50);
      });
    });
  });
}

class BadEffect extends Effect implements MeasurableEffect {
  BadEffect(EffectController controller) : super(controller);

  @override
  void apply(double progress) {}

  @override
  double measure() => -1;
}
