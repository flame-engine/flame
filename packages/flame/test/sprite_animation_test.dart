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
      final sprite = MockSprite();
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
      final sprite = MockSprite();
      final animation =
          SpriteAnimation.spriteList([sprite, sprite, sprite], stepTime: 1);
      expect(
        () => animation.stepTime = 0,
        failsAssert('Step time must be positive'),
      );
      expect(
        () => animation.variableStepTimes = [3, 2, 0],
        failsAssert('All step times must be positive'),
      );
    });

    test('onComplete called for single-frame animation', () {
      var counter = 0;
      final sprite = MockSprite();
      final animation = SpriteAnimation.spriteList(
        [sprite],
        stepTime: 1,
        loop: false,
      )..onComplete = () => counter++;

      expect(counter, 0);
      animation.update(0.5);
      expect(counter, 0);
      animation.update(0.5);
      expect(counter, 1);
      animation.update(1);
      expect(counter, 1);
    });

    test('completed completes', () {
      final sprite = MockSprite();
      final animation = SpriteAnimation.spriteList(
        [sprite],
        stepTime: 1,
        loop: false,
      );

      expectLater(animation.completed, completes);

      animation.update(1);
    });

    test(
      'completed completes when animation has alrady completed',
      () async {
        final sprite = MockSprite();
        final animation = SpriteAnimation.spriteList(
          [sprite],
          stepTime: 1,
          loop: false,
        );

        animation.update(1);

        expectLater(animation.completed, completes);
      },
    );

    test(
      "completed doesn't complete when the animation is yet to complete",
      () async {
        final sprite = MockSprite();
        final animation = SpriteAnimation.spriteList(
          [sprite],
          stepTime: 1,
          loop: false,
        );

        expectLater(animation.completed, doesNotComplete);
      },
    );

    test(
      "completed doesn't complete when animation is looping",
      () async {
        final sprite = MockSprite();
        final animation = SpriteAnimation.spriteList([sprite], stepTime: 1);

        expectLater(animation.completed, doesNotComplete);
      },
    );

    test(
      "completed doesn't completes when animation is looping and on last frame",
      () async {
        final sprite = MockSprite();
        final animation = SpriteAnimation.spriteList([sprite], stepTime: 1);

        animation.update(1);

        expectLater(animation.completed, doesNotComplete);
      },
    );
  });
}

class MockSprite extends Mock implements Sprite {}
