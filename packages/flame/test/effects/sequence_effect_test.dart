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

        var time = 0.0;
        while (time < 10) {
          final x = time <= 1
              ? time * 10
              : time <= 3
                  ? 10
                  : time <= 6
                      ? 10 - 10 * (time - 3) / 3
                      : 30 * (time - 6) / 4;
          final y = time <= 1
              ? 0
              : time <= 3
                  ? 10 * (time - 1) / 2
                  : time <= 6
                      ? 10
                      : 10 + 30 * (time - 6) / 4;
          expect(component.position, closeToVector(x, y, epsilon: 1e-12));
          time += 0.1;
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
        for (var i = 0; i < 40; i++) {
          final p = expectedPath[i];
          expect(component.position, closeToVector(p.x, p.y, epsilon: 1e-14));
          game.update(0.1);
        }
        game.update(0.1);
        expect(effect.controller.completed, true);
      });
    });
  });
}
