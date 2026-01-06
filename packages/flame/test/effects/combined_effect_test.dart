import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CombinedEffect', () {
    group('properties', () {
      test('simple', () {
        final effect = CombinedEffect([
          MoveEffect.to(Vector2(10, 10), EffectController(duration: 3)),
          MoveEffect.by(
            Vector2(1, 0),
            EffectController(duration: 0.1, repeatCount: 15),
          ),
        ]);
        expect(effect.controller.duration, 3.0);
        expect(effect.controller.isRandom, false);
        expect(effect.controller.completed, false);
      });

      test('alternating', () {
        final effect = CombinedEffect(
          [
            MoveEffect.to(Vector2(10, 10), EffectController(duration: 3)),
          ],
          alternate: true,
        );
        expect(effect.controller.duration, 6);
        expect(effect.controller.isRandom, false);
      });

      test('errors', () {
        expect(
          () => CombinedEffect(<Effect>[]),
          failsAssert('The list of effects cannot be empty'),
        );
        expect(
          () => CombinedEffect(
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

    group('combination progression', () {
      testWithFlameGame('simple combination', (game) async {
        final effect = CombinedEffect([
          MoveEffect.by(Vector2(10, 0), EffectController(duration: 1)),
          ScaleEffect.to(Vector2.all(3), EffectController(duration: 2)),
        ]);
        final component = PositionComponent()..add(effect);
        game.add(component);
        await game.ready();

        game.update(0.5);
        expect(component.position, closeToVector(Vector2(5, 0)));
        expect(component.scale, closeToVector(Vector2(1.5, 1.5)));

        game.update(0.5);
        expect(component.position, closeToVector(Vector2(10, 0)));
        expect(component.scale, closeToVector(Vector2(2, 2)));

        game.update(0.5);
        expect(component.position, closeToVector(Vector2(10, 0)));
        expect(component.scale, closeToVector(Vector2(2.5, 2.5)));

        game.update(0.5);
        expect(component.position, closeToVector(Vector2(10, 0)));
        expect(component.scale, closeToVector(Vector2(3, 3)));
        expect(effect.controller.completed, true);
      });

      testWithFlameGame('alternating combination', (game) async {
        final effect = CombinedEffect(
          [
            MoveEffect.by(Vector2(10, 0), EffectController(duration: 1)),
            ScaleEffect.to(Vector2.all(3), EffectController(duration: 2)),
          ],
          alternate: true,
        );
        final component = PositionComponent()..add(effect);
        game.add(component);
        await game.ready();

        game.update(0.5);
        expect(component.position, closeToVector(Vector2(5, 0)));
        expect(component.scale, closeToVector(Vector2(1.5, 1.5)));

        game.update(0.5);
        expect(component.position, closeToVector(Vector2(10, 0)));
        expect(component.scale, closeToVector(Vector2(2, 2)));
        expect(component.position, closeToVector(Vector2(10, 0)));

        game.update(0.5);
        expect(component.scale, closeToVector(Vector2(2.5, 2.5)));

        game.update(0.5);
        expect(component.scale, closeToVector(Vector2(3, 3)));

        // Alternating
        game.update(0.5);
        expect(component.position, closeToVector(Vector2(5, 0)));
        expect(component.scale, closeToVector(Vector2(2.5, 2.5)));

        game.update(0.5);
        expect(component.position, closeToVector(Vector2(0, 0)));
        expect(component.scale, closeToVector(Vector2(2, 2)));

        game.update(0.5);
        expect(component.scale, closeToVector(Vector2(1.5, 1.5)));

        game.update(0.5);
        expect(component.scale, closeToVector(Vector2(1, 1)));
        expect(effect.controller.completed, true);
      });
      testWithFlameGame('infinite alternating combination', (game) async {
        final effect = CombinedEffect(
          [
            MoveEffect.by(Vector2(10, 0), EffectController(duration: 1)),
            ScaleEffect.to(Vector2.all(3), EffectController(duration: 2)),
          ],
          alternate: true,
          infinite: true,
        );
        final component = PositionComponent()..add(effect);
        game.add(component);
        await game.ready();

        game.update(1);
        expect(component.position, closeToVector(Vector2(10, 0)));
        expect(component.scale, closeToVector(Vector2(2, 2)));

        game.update(1);
        expect(component.position, closeToVector(Vector2(10, 0)));
        expect(component.scale, closeToVector(Vector2(3, 3)));

        // Alternating
        game.update(1);
        expect(component.position, closeToVector(Vector2(0, 0)));
        expect(component.scale, closeToVector(Vector2(2, 2)));

        game.update(1);
        expect(component.position, closeToVector(Vector2(0, 0)));
        expect(component.scale, closeToVector(Vector2(1, 1)));
        expect(effect.controller.completed, false);

        // Infinite
        game.update(1);
        expect(component.position, closeToVector(Vector2(10, 0)));
        expect(component.scale, closeToVector(Vector2(2, 2)));
      });
    });
  });
}
