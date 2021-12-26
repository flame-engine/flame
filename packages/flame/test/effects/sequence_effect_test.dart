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
        final effect = SequenceEffect(
          [
            MoveEffect.by(Vector2(10, 10), duration(1)),
            SequenceEffect(
              [
                MoveEffect.to(Vector2(20, 0), duration(1)),
                MoveEffect.to(Vector2(30, 10), duration(1)),
              ],
              alternate: true,
              repeatCount: 2,
            ),
            MoveEffect.by(Vector2(0, 20), duration(2)),
            SequenceEffect(
              [
                MoveEffect.by(Vector2(1, 0), duration(1)),
                MoveEffect.by(Vector2(0, 1), duration(1)),
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

        final forwardPath = <Vector2>[
          for (var i = 0; i < 100; i++) Vector2(i * 0.1, i * 0.1),
          for (var i = 0; i < 100; i++) Vector2(10 + i * 0.1, 10 - i * 0.1),
          for (var i = 0; i < 100; i++) Vector2(20 + i * 0.1, i * 0.1),
          for (var i = 100; i > 0; i--) Vector2(20 + i * 0.1, i * 0.1),
          for (var i = 100; i > 0; i--) Vector2(10 + i * 0.1, 10 - i * 0.1),
          for (var i = 0; i < 100; i++) Vector2(10 + i * 0.1, 10 - i * 0.1),
          for (var i = 0; i < 100; i++) Vector2(20 + i * 0.1, i * 0.1),
          for (var i = 100; i > 0; i--) Vector2(20 + i * 0.1, i * 0.1),
          for (var i = 100; i > 0; i--) Vector2(10 + i * 0.1, 10 - i * 0.1),
          for (var i = 0; i < 200; i++) Vector2(10, 10 + i * 0.1),
          for (var j = 0; j < 5; j++)
            for (var i = 0; i < 200; i++)
              Vector2(i < 100 ? i * 0.01 : 1, i < 100 ? 0 : i * 0.01 - 1)
                ..add(Vector2(10 + j * 1.0, 30 + j * 1.0)),
        ];
        final expectedPath = <Vector2>[
          ...forwardPath,
          Vector2(15, 35),
          ...forwardPath.reversed,
        ];
        for (final p in expectedPath) {
          expect(component.position, closeToVector(p.x, p.y, epsilon: 1e-12));
          game.update(0.01);
        }
        game.update(1e-5);
        expect(effect.controller.completed, true);
      });
    });
  });
}
