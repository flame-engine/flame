import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

enum _AnimationState {
  idle,
  running,
}

Future<void> main() async {
  // Generate a image
  final image = await generateImage();

  group('SpriteAnimationGroupComponent', () {
    test('returns the correct animation according to its state', () {
      final animation1 = SpriteAnimation.spriteList(
        [
          Sprite(image),
          Sprite(image),
        ],
        stepTime: 1,
      );
      final animation2 = SpriteAnimation.spriteList(
        [
          Sprite(image),
          Sprite(image),
        ],
        stepTime: 1,
      );
      final component = SpriteAnimationGroupComponent<_AnimationState>(
        animations: {
          _AnimationState.idle: animation1,
          _AnimationState.running: animation2,
        },
      );

      // No state was specified so nothing is playing
      expect(component.animation, null);

      // Setting the idle state, we need to see the animation1
      component.current = _AnimationState.idle;
      expect(component.animation, animation1);

      // Setting the running state, we need to see the animation2
      component.current = _AnimationState.running;
      expect(component.animation, animation2);
    });

    test('Asserts that map contains key', () {
      expect(
        () {
          SpriteAnimationGroupComponent<String>(animations: {}).current =
              'non-existent-key';
        },
        failsAssert('Animation not found for key: non-existent-key'),
      );
    });
  });

  group('SpriteAnimationGroupComponent.shouldRemove', () {
    testWithFlameGame('removeOnFinish is true and there is no any state yet', (
      game,
    ) async {
      final animation = SpriteAnimation.spriteList(
        [
          Sprite(image),
          Sprite(image),
        ],
        stepTime: 1,
        loop: false,
      );
      final component = SpriteAnimationGroupComponent<_AnimationState>(
        animations: {_AnimationState.idle: animation},
        removeOnFinish: {_AnimationState.idle: true},
      );

      final world = game.world;
      await world.ensureAdd(component);
      expect(component.parent, world);
      expect(world.children.length, 1);

      game.update(2);
      expect(component.parent, world);

      // runs a cycle and the component should still be there
      game.update(0.1);
      expect(world.children.length, 1);
    });

    testWithFlameGame(
      'removeOnFinish is true and current state animation#loop is false',
      (game) async {
        final animation = SpriteAnimation.spriteList(
          [
            Sprite(image),
            Sprite(image),
          ],
          stepTime: 1,
          loop: false,
        );
        final component = SpriteAnimationGroupComponent<_AnimationState>(
          animations: {_AnimationState.idle: animation},
          removeOnFinish: {_AnimationState.idle: true},
          current: _AnimationState.idle,
        );

        final world = game.world;
        await world.ensureAdd(component);
        expect(world.children.length, 1);

        game.update(2);

        // runs a cycle to remove the component
        game.update(0.1);
        expect(world.children.length, 0);
      },
    );

    testWithFlameGame(
      'removeOnFinish is true and current animation#loop is true',
      (game) async {
        final animation = SpriteAnimation.spriteList(
          [
            Sprite(image),
            Sprite(image),
          ],
          stepTime: 1,
          // ignore: avoid_redundant_argument_values
          loop: true,
        );
        final component = SpriteAnimationGroupComponent<_AnimationState>(
          animations: {_AnimationState.idle: animation},
          removeOnFinish: {_AnimationState.idle: true},
          current: _AnimationState.idle,
        );

        final world = game.world;
        await world.ensureAdd(component);
        expect(component.parent, world);
        expect(world.children.length, 1);

        game.update(2);
        expect(component.parent, world);

        // runs a cycle to remove the component, but failed
        game.update(0.1);
        expect(world.children.length, 1);
      },
    );

    testWithFlameGame(
      'removeOnFinish is false and current animation#loop is false',
      (game) async {
        final animation = SpriteAnimation.spriteList(
          [
            Sprite(image),
            Sprite(image),
          ],
          stepTime: 1,
          loop: false,
        );
        final component = SpriteAnimationGroupComponent<_AnimationState>(
          animations: {_AnimationState.idle: animation},
          current: _AnimationState.idle,
          // when omitted, removeOnFinish is false for all states
        );

        final world = game.world;
        await world.ensureAdd(component);
        expect(component.parent, world);
        expect(world.children.length, 1);

        game.update(2);
        expect(component.parent, world);

        // runs a cycle to remove the component, but failed
        game.update(0.1);
        expect(world.children.length, 1);
      },
    );

    testWithFlameGame(
      'removeOnFinish is false and current animation#loop is true',
      (game) async {
        final animation = SpriteAnimation.spriteList(
          [
            Sprite(image),
            Sprite(image),
          ],
          stepTime: 1,
          // ignore: avoid_redundant_argument_values
          loop: true,
        );
        final component = SpriteAnimationGroupComponent<_AnimationState>(
          animations: {_AnimationState.idle: animation},
          // when omitted, removeOnFinish is false for all states
          current: _AnimationState.idle,
        );

        final world = game.world;
        await world.ensureAdd(component);

        expect(component.parent, world);
        expect(world.children.length, 1);

        game.update(2);
        expect(component.parent, world);

        // runs a cycle to remove the component, but failed
        game.update(0.1);
        expect(world.children.length, 1);
      },
    );
  });

  group('SpriteAnimationGroupComponent.currentAnimationNotifier', () {
    test('notifies when the current animation changes', () {
      final sprite1 = Sprite(image, srcSize: Vector2.all(76));
      final sprite2 = Sprite(image, srcSize: Vector2.all(15));
      final animation1 = SpriteAnimation.spriteList(
        List.filled(5, sprite1),
        stepTime: 1,
        loop: false,
      );
      final animation2 = SpriteAnimation.spriteList(
        [sprite2, sprite1],
        stepTime: 1,
      );
      final animationsMap = {
        _AnimationState.idle: animation1,
        _AnimationState.running: animation2,
      };
      final component = SpriteAnimationGroupComponent<_AnimationState>(
        animations: animationsMap,
      );
      var animationChangeCounter = 0;
      component.currentAnimationNotifier.addListener(
        () => animationChangeCounter++,
      );

      component.current = _AnimationState.running;
      expect(animationChangeCounter, equals(1));

      component.current = _AnimationState.idle;
      expect(animationChangeCounter, equals(2));

      component.update(1);
      expect(animationChangeCounter, equals(2));

      component.current = _AnimationState.running;
      expect(animationChangeCounter, equals(3));

      component.update(1);
      expect(animationChangeCounter, equals(3));

      component.current = _AnimationState.running;
      component.update(1);
      expect(animationChangeCounter, equals(3));
    });
  });
}
