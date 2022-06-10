import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

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
  });

  group('SpriteAnimationGroupComponent.shouldRemove', () {
    flameGame.test('removeOnFinish is true and there is no any state yet',
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
      );

      await game.ensureAdd(component);
      expect(component.parent, game);
      expect(game.children.length, 1);

      game.update(2);
      expect(component.parent, game);

      // runs a cycle and the component should still be there
      game.update(0.1);
      expect(game.children.length, 1);
    });

    flameGame.test(
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

        await game.ensureAdd(component);
        expect(game.children.length, 1);

        game.update(2);

        // runs a cycle to remove the component
        game.update(0.1);
        expect(game.children.length, 0);
      },
    );

    flameGame.test('removeOnFinish is true and current animation#loop is true',
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

      await game.ensureAdd(component);
      expect(component.parent, game);
      expect(game.children.length, 1);

      game.update(2);
      expect(component.parent, game);

      // runs a cycle to remove the component, but failed
      game.update(0.1);
      expect(game.children.length, 1);
    });

    flameGame
        .test('removeOnFinish is false and current animation#loop is false',
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

      await game.ensureAdd(component);
      expect(component.parent, game);
      expect(game.children.length, 1);

      game.update(2);
      expect(component.parent, game);

      // runs a cycle to remove the component, but failed
      game.update(0.1);
      expect(game.children.length, 1);
    });

    flameGame.test('removeOnFinish is false and current animation#loop is true',
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

      await game.ensureAdd(component);

      expect(component.parent, game);
      expect(game.children.length, 1);

      game.update(2);
      expect(component.parent, game);

      // runs a cycle to remove the component, but failed
      game.update(0.1);
      expect(game.children.length, 1);
    });
  });
}
