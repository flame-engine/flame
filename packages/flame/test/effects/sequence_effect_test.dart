import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SequenceEffect', () {
    group('properties', () {
      test('simple', () {
        final effect = SequenceEffect([
          MoveEffect.to(Vector2(10, 10), EffectController(duration: 3)),
          MoveEffect.by(
            Vector2(1, 0),
            EffectController(duration: 0.1, repeatCount: 15),
          ),
        ]);
        expect(effect.controller.duration, 4.5);
        expect(effect.controller.isRandom, false);
        expect(effect.controller.completed, false);
      });

      test('alternating', () {
        final effect = SequenceEffect(
          [
            MoveEffect.to(Vector2(10, 10), EffectController(duration: 3)),
          ],
          alternate: true,
        );
        expect(effect.controller.duration, 6);
        expect(effect.controller.isRandom, false);
      });

      test('infinite', () {
        final effect = SequenceEffect(
          [
            MoveEffect.to(Vector2.zero(), EffectController(duration: 1)),
          ],
          alternate: true,
          infinite: true,
        );
        expect(effect.controller.duration, double.infinity);
        expect(effect.controller.isRandom, false);
      });

      test('with random effects', () {
        final randomEffect = MoveEffect.to(
          Vector2(10, 10),
          RandomEffectController.uniform(
            LinearEffectController(0),
            min: 1,
            max: 5,
          ),
        );
        final effect = SequenceEffect(
          [randomEffect],
          alternate: true,
          repeatCount: 1000,
        );
        expect(
          effect.controller.duration,
          closeTo(randomEffect.controller.duration! * 2000, 1e-15),
        );
        expect(effect.controller.isRandom, true);
      });

      test('errors', () {
        expect(
          () => SequenceEffect(<Effect>[]),
          failsAssert('The list of effects cannot be empty'),
        );
        expect(
          () => SequenceEffect(
            [MoveEffect.to(Vector2.zero(), EffectController(duration: 1))],
            infinite: true,
            repeatCount: 10,
          ),
          failsAssert(
            'Parameters infinite and repeatCount cannot be specified '
            'simultaneously',
          ),
        );
      });
    });

    group('sequence progression', () {
      test('simple sequence', () async {
        final effect = SequenceEffect([
          MoveEffect.by(Vector2(10, 0), EffectController(duration: 1)),
          MoveEffect.by(Vector2(0, 10), EffectController(duration: 2)),
          MoveEffect.by(Vector2(-10, 0), EffectController(duration: 3)),
          MoveEffect.by(Vector2(30, 30), EffectController(duration: 4)),
        ]);
        final component = PositionComponent()..add(effect);

        final game = FlameGame()..onGameResize(Vector2.all(1000));
        await game.ensureAdd(component);
        game.update(0);

        // Each point here is spaced 0.1 seconds apart
        final expectedPositions = <Vector2>[
          ...List.generate(10, (i) => Vector2(i * 1.0, 0)),
          ...List.generate(20, (i) => Vector2(10, i * 0.5)),
          ...List.generate(30, (i) => Vector2(10 - i / 3, 10)),
          ...List.generate(40, (i) => Vector2(i * 0.75, 10 + i * 0.75)),
          Vector2(30, 40),
        ];
        for (final p in expectedPositions) {
          expect(component.position, closeToVector(p.x, p.y, epsilon: 1e-12));
          game.update(0.1);
        }
      });

      test('large step', () async {
        final effect = SequenceEffect([
          MoveEffect.by(Vector2(10, 0), EffectController(duration: 1)),
          MoveEffect.by(Vector2(0, 10), EffectController(duration: 2)),
          MoveEffect.by(Vector2(-10, 0), EffectController(duration: 3)),
          MoveEffect.by(Vector2(30, 30), EffectController(duration: 4)),
        ]);
        final component = PositionComponent()..add(effect);

        final game = FlameGame()..onGameResize(Vector2.all(1000));
        await game.ensureAdd(component);

        game.update(10);
        expect(component.position, closeToVector(30, 40));
      });

      test('k-step sequence', () async {
        final effect = SequenceEffect(
          [
            MoveEffect.by(Vector2(10, 0), EffectController(duration: 1)),
            MoveEffect.by(Vector2(0, 10), EffectController(duration: 1)),
          ],
          repeatCount: 5,
        );
        final component = PositionComponent()..add(effect);
        final game = FlameGame()..onGameResize(Vector2.all(1000));
        await game.ensureAdd(component);

        for (var i = 0; i < 10; i++) {
          final x = ((i + 1) ~/ 2) * 10;
          final y = (i ~/ 2) * 10;
          expect(component.position, closeToVector(x, y));
          expect(effect.isMounted, true);
          game.update(1);
        }
        game.update(5); // Will schedule the `effect` component for deletion
        game.update(0); // Second update ensures the game deletes the component
        expect(effect.isMounted, false);
        expect(component.position, closeToVector(50, 50));
      });

      test('alternating sequence', () async {
        final effect = SequenceEffect(
          [
            MoveEffect.by(Vector2(10, 0), EffectController(duration: 1)),
            MoveEffect.by(Vector2(0, 10), EffectController(duration: 1)),
          ],
          alternate: true,
        );
        expect(effect.controller.duration, 4);

        final component = PositionComponent()..add(effect);
        final game = FlameGame()..onGameResize(Vector2.all(1000));
        await game.ensureAdd(component);
        game.update(0);

        final expectedPath = <Vector2>[
          for (var i = 0.0; i < 10; i++) Vector2(i, 0),
          for (var i = 0.0; i < 10; i++) Vector2(10, i),
          for (var i = 10.0; i > 0; i--) Vector2(10, i),
          for (var i = 10.0; i > 0; i--) Vector2(i, 0),
        ];
        for (final p in expectedPath) {
          expect(component.position, closeToVector(p.x, p.y, epsilon: 1e-14));
          game.update(0.1);
        }
        game.update(0.001);
        expect(effect.controller.completed, true);
      });

      test('sequence of alternates', () async {
        EffectController controller() =>
            EffectController(duration: 1, alternate: true);
        final effect = SequenceEffect(
          [
            MoveEffect.by(Vector2(1, 0), controller()),
            MoveEffect.by(Vector2(0, 1), controller()),
          ],
          alternate: true,
        );

        final component = PositionComponent()..add(effect);
        final game = FlameGame()..onGameResize(Vector2.all(1000));
        await game.ensureAdd(component);
        game.update(0);

        final forwardPath = <Vector2>[
          for (var i = 0; i < 10; i++) Vector2(i * 0.1, 0),
          for (var i = 10; i > 0; i--) Vector2(i * 0.1, 0),
          for (var i = 0; i < 10; i++) Vector2(0, i * 0.1),
          for (var i = 10; i > 0; i--) Vector2(0, i * 0.1),
        ];
        final expectedPath = [
          ...forwardPath,
          Vector2.zero(),
          ...forwardPath.reversed,
        ];
        for (final p in expectedPath) {
          expect(component.position, closeToVector(p.x, p.y, epsilon: 1e-14));
          game.update(0.1);
        }
        game.update(0.001);
        expect(component.position, closeToVector(0, 0));
        expect(effect.controller.completed, true);
      });

      test('sequence in sequence', () async {
        EffectController duration(double t) => EffectController(duration: t);
        const dt = 0.01;
        const x0 = 0.0, y0 = 0.0;
        const x1 = 10.0, y1 = 10.0;
        const x2 = 20.0, y2 = 0.0;
        const x3 = 30.0, y3 = 10.0;
        const x4 = 10.0, y4 = 30.0;
        const dx5 = 1.6, dy5 = 0.9;

        final effect = SequenceEffect(
          [
            MoveEffect.by(Vector2(x1 - x0, y1 - y0), duration(1)),
            SequenceEffect(
              [
                MoveEffect.to(Vector2(x2, y2), duration(1)),
                MoveEffect.to(Vector2(x3, y3), duration(1)),
              ],
              alternate: true,
              repeatCount: 2,
            ),
            MoveEffect.by(Vector2(x4 - x1, y4 - y1), duration(2)),
            SequenceEffect(
              [
                MoveEffect.by(Vector2(dx5, 0), duration(1)),
                MoveEffect.by(Vector2(0, dy5), duration(1)),
              ],
              repeatCount: 5,
            ),
          ],
          alternate: true,
        );
        expect(effect.controller.duration, 42);

        final component = PositionComponent()..add(effect);
        final game = FlameGame()..onGameResize(Vector2.all(1000));
        await game.ensureAdd(component);
        game.update(0);

        // All points here are spaced `dt = 0.01` apart
        final forwardPath = <Vector2>[
          // First MoveEffect
          for (var t = 0.0; t < 1; t += dt)
            Vector2(x0 + (x1 - x0) * t, y0 + (y1 - y0) * t),
          // First SequenceEffect
          for (var t = 0.0; t < 1; t += dt)
            Vector2(x1 + (x2 - x1) * t, y1 + (y2 - y1) * t),
          for (var t = 0.0; t < 1; t += dt)
            Vector2(x2 + (x3 - x2) * t, y2 + (y3 - y2) * t),
          for (var t = 1.0; t > 0; t -= dt)
            Vector2(x2 + (x3 - x2) * t, y2 + (y3 - y2) * t),
          for (var t = 1.0; t > 0; t -= dt)
            Vector2(x1 + (x2 - x1) * t, y1 + (y2 - y1) * t),
          // First SequenceEffect, repeated second time
          for (var t = 0.0; t < 1; t += dt)
            Vector2(x1 + (x2 - x1) * t, y1 + (y2 - y1) * t),
          for (var t = 0.0; t < 1; t += dt)
            Vector2(x2 + (x3 - x2) * t, y2 + (y3 - y2) * t),
          for (var t = 1.0; t > 0; t -= dt)
            Vector2(x2 + (x3 - x2) * t, y2 + (y3 - y2) * t),
          for (var t = 1.0; t > 0; t -= dt)
            Vector2(x1 + (x2 - x1) * t, y1 + (y2 - y1) * t),
          // Second MoveEffect, duration = 2
          for (var t = 0.0; t < 2; t += dt)
            Vector2(x1 + (x4 - x1) * t, y1 + (y4 - y1) * t / 2),
          // Second sequence effect, repeated 5 times
          for (var j = 0; j < 5; j++)
            for (var t = 0.0; t < 2; t += dt)
              Vector2(
                x4 + min(j + t, j + 1) * dx5,
                y4 + max(j + t - 1, j) * dy5,
              ),
        ];
        final expectedPath = <Vector2>[
          ...forwardPath,
          Vector2(x4 + 5 * dx5, y4 + 5 * dy5),
          ...forwardPath.reversed,
        ];
        for (final p in expectedPath) {
          expect(component.position, closeToVector(p.x, p.y, epsilon: 1e-12));
          game.update(dt);
        }
        game.update(1e-5);
        expect(effect.controller.completed, true);
      });
    });
  });
}
