import 'package:flame/extensions.dart';
import 'package:flame/src/sprite_animation.dart';
import 'package:flame_test/flame_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('SpriteAnimation', () {
    test('Throw assertion error on empty list of frames', () {
      expect(
        () => SpriteAnimation.spriteList([], stepTime: 1),
        failsAssert('There must be at least one animation frame'),
      );
    });

    test('Throw assertion error on non-positive step time', () {
      final sprite = _MockSprite();
      expect(
        () => SpriteAnimation.spriteList([sprite], stepTime: 0),
        failsAssert('All frames must have positive durations'),
      );
      expect(
        () => SpriteAnimation.variableSpriteList(
          [sprite, sprite, sprite],
          stepTimes: [1, -1, 0],
        ),
        failsAssert('All frames must have positive durations'),
      );
    });

    test('Throw assertion error when setting non-positive step time', () {
      final sprite = _MockSprite();
      final animation = SpriteAnimation.spriteList([
        sprite,
        sprite,
        sprite,
      ], stepTime: 1);
      expect(
        () => animation.stepTime = 0,
        failsAssert('Step time must be positive'),
      );
      expect(
        () => animation.variableStepTimes = [3, 2, 0],
        failsAssert('All step times must be positive'),
      );
    });
  });

  group('SpriteAnimationData', () {
    test(
      'throws assertion error when amountPerRow is greater than amount',
      () {
        expect(
          () => SpriteAnimationData.variable(
            amount: 5,
            stepTimes: List.filled(5, 0.1),
            textureSize: Vector2(50, 50),
            amountPerRow: 10,
          ),
          failsAssert(),
        );
      },
    );

    test('creates a new SpriteAnimationData using the range constructor', () {
      final animationData = SpriteAnimationData.range(
        start: 6,
        end: 11,
        amount: 18,
        stepTimes: [0.1, 0.2, 0.3, 0.4, 0.5, 0.6],
        amountPerRow: 6,
        textureSize: Vector2(1, 1),
      );
      expect(animationData.frames.length, 6);
      expect(
        animationData.frames.map((f) => f.stepTime),
        [0.1, 0.2, 0.3, 0.4, 0.5, 0.6],
      );
      expect(animationData.frames.map((f) => f.srcPosition), [
        Vector2(0, 1),
        Vector2(1, 1),
        Vector2(2, 1),
        Vector2(3, 1),
        Vector2(4, 1),
        Vector2(5, 1),
      ]);
    });
  });
}

class _MockSprite extends Mock implements Sprite {}
