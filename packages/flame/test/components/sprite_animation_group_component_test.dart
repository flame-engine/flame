import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/test.dart';
import 'package:test/test.dart';

enum AnimationState {
  idle,
  running,
}

void main() async {
  // Generate a image
  final image = await generateImage();

  final size = Vector2(1.0, 1.0);

  group('SpriteAnimationGroupComponent test', () {
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
      final component = SpriteAnimationGroupComponent<AnimationState>(
        animations: {
          AnimationState.idle: animation1,
          AnimationState.running: animation2,
        },
      );

      // No state was specified so nothing is playing
      expect(component.animation, null);

      // Setting the idle state, we need to see the animation1
      component.current = AnimationState.idle;
      expect(component.animation, animation1);

      // Setting the running state, we need to see the animation2
      component.current = AnimationState.running;
      expect(component.animation, animation2);
    });
  });
  group('SpriteAnimationGroupComponent shouldRemove test', () {
    test('removeOnFinish is true and there is no any state yet', () {
      final game = FlameGame();
      final animation = SpriteAnimation.spriteList(
        [
          Sprite(image),
          Sprite(image),
        ],
        stepTime: 1,
        loop: false,
      );
      final component = SpriteAnimationGroupComponent<AnimationState>(
        animations: {AnimationState.idle: animation},
        removeOnFinish: {AnimationState.idle: true},
      );

      game.onGameResize(size);
      game.add(component);

      // runs a cycle to add the component
      game.update(0.1);
      expect(component.shouldRemove, false);
      expect(game.children.length, 1);

      game.update(2);
      expect(component.shouldRemove, false);

      // runs a cycle and the component should still be there
      game.update(0.1);
      expect(game.children.length, 1);
    });

    test(
      'removeOnFinish is true and current state animation#loop is false',
      () {
        final game = FlameGame();
        final animation = SpriteAnimation.spriteList(
          [
            Sprite(image),
            Sprite(image),
          ],
          stepTime: 1,
          loop: false,
        );
        final component = SpriteAnimationGroupComponent<AnimationState>(
          animations: {AnimationState.idle: animation},
          removeOnFinish: {AnimationState.idle: true},
          current: AnimationState.idle,
        );

        game.onGameResize(size);
        game.add(component);

        // runs a cycle to add the component
        game.update(0.1);
        expect(component.shouldRemove, false);
        expect(game.children.length, 1);

        game.update(2);
        expect(component.shouldRemove, true);

        // runs a cycle to remove the component
        game.update(0.1);
        expect(game.children.length, 0);
      },
    );

    test('removeOnFinish is true and current animation#loop is true', () {
      final game = FlameGame();
      final animation = SpriteAnimation.spriteList(
        [
          Sprite(image),
          Sprite(image),
        ],
        stepTime: 1,
        // ignore: avoid_redundant_argument_values
        loop: true,
      );
      final component = SpriteAnimationGroupComponent<AnimationState>(
        animations: {AnimationState.idle: animation},
        removeOnFinish: {AnimationState.idle: true},
        current: AnimationState.idle,
      );

      game.onGameResize(size);
      game.add(component);

      // runs a cycle to add the component
      game.update(0.1);
      expect(component.shouldRemove, false);
      expect(game.children.length, 1);

      game.update(2);
      expect(component.shouldRemove, false);

      // runs a cycle to remove the component, but failed
      game.update(0.1);
      expect(game.children.length, 1);
    });

    test('removeOnFinish is false and current animation#loop is false', () {
      final game = FlameGame();
      final animation = SpriteAnimation.spriteList(
        [
          Sprite(image),
          Sprite(image),
        ],
        stepTime: 1,
        loop: false,
      );
      final component = SpriteAnimationGroupComponent<AnimationState>(
        animations: {AnimationState.idle: animation},
        current: AnimationState.idle,
        // when omited, removeOnFinish is false for all states
      );

      game.onGameResize(size);
      game.add(component);

      // runs a cycle to add the component
      game.update(0.1);
      expect(component.shouldRemove, false);
      expect(game.children.length, 1);

      game.update(2);
      expect(component.shouldRemove, false);

      // runs a cycle to remove the component, but failed
      game.update(0.1);
      expect(game.children.length, 1);
    });

    test('removeOnFinish is false and current animation#loop is true', () {
      final game = FlameGame();
      final animation = SpriteAnimation.spriteList(
        [
          Sprite(image),
          Sprite(image),
        ],
        stepTime: 1,
        // ignore: avoid_redundant_argument_values
        loop: true,
      );
      final component = SpriteAnimationGroupComponent<AnimationState>(
        animations: {AnimationState.idle: animation},
        // when omited, removeOnFinish is false for all states
        current: AnimationState.idle,
      );

      game.onGameResize(size);
      game.add(component);

      // runs a cycle to add the component
      game.update(0.1);
      expect(component.shouldRemove, false);
      expect(game.children.length, 1);

      game.update(2);
      expect(component.shouldRemove, false);

      // runs a cycle to remove the component, but failed
      game.update(0.1);
      expect(game.children.length, 1);
    });
  });
}
