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

    test('onStart called for single-frame animation', () {
      var counter = 0;
      final sprite = MockSprite();
      final animation =
          SpriteAnimation.spriteList([sprite], stepTime: 1, loop: false)
            ..onStart = () => counter++;
      expect(counter, 0);
      animation.update(0.5);
      expect(counter, 1);
      animation.update(1);
      expect(counter, 1);
    });

    test('onFrame called for a multi-frame animation', () {
      var counter = 0;
      var i = 0;
      const animationLength = 3;
      final sprite = MockSprite();
      final animation = SpriteAnimation.spriteList([sprite, sprite, sprite],
          stepTime: 1, loop: false);
      animation.onFrame = (index) {
        counter++;
      };
      for (i = 0; i <= animationLength; i++) {
        expect(counter, i);
        animation.update(1);
      }
      expect(counter, 3);
      expect(i, 4);
    });

    test('onComplete called for single-frame animation', () {
      var counter = 0;
      final sprite = MockSprite();
      final animation =
          SpriteAnimation.spriteList([sprite], stepTime: 1, loop: false)
            ..onComplete = () => counter++;
      expect(counter, 0);
      animation.update(0.5);
      expect(counter, 0);
      animation.update(0.5);
      expect(counter, 1);
      animation.update(1);
      expect(counter, 1);
    });

    test('test sequence of event lifecycle for an animation', () {
      var animationStarted = false;
      var animationRunning = false;
      var animationComplete = false;
      final sprite = MockSprite();
      final animation =
          SpriteAnimation.spriteList([sprite], stepTime: 1, loop: false);
      animation.onStart = () {
        expect(animationStarted, false);
        expect(animationRunning, false);
        expect(animationComplete, false);
        animationStarted = true;
      };
      animation.onFrame = (index) {
        if (index == 0) {
          expect(animationStarted, true);
          expect(animationRunning, false);
          expect(animationComplete, false);
        }
        if (index == 1) {
          expect(animationStarted, true);
          expect(animationRunning, true);
          expect(animationComplete, false);
        }
        animationRunning = true;
      };
      animation.onComplete = () {
        expect(animationStarted, true);
        expect(animationRunning, true);
        expect(animationComplete, false);
        animationComplete = true;
      };
      animation.update(1);
      expect(animationComplete, true);
    });
  });
}

class MockSprite extends Mock implements Sprite {}
