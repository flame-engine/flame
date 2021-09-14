import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/test.dart';
import 'package:test/test.dart';

void main() async {
  // Generate an image
  final image = await generateImage();

  final size = Vector2(1.0, 1.0);

  group('SpriteAnimationComponent shouldRemove test', () {
    test('removeOnFinish is true and animation#loop is false', () {
      final game = FlameGame();
      final animation = SpriteAnimation.spriteList(
        [
          Sprite(image),
          Sprite(image),
        ],
        stepTime: 1,
        loop: false,
      );
      final component = SpriteAnimationComponent(
        animation: animation,
        removeOnFinish: true,
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
    });

    test('removeOnFinish is true and animation#loop is true', () {
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
      final component = SpriteAnimationComponent(
        animation: animation,
        removeOnFinish: true,
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

    test('removeOnFinish is false and animation#loop is false', () {
      final game = FlameGame();
      final animation = SpriteAnimation.spriteList(
        [
          Sprite(image),
          Sprite(image),
        ],
        stepTime: 1,
        loop: false,
      );
      final component = SpriteAnimationComponent(
        animation: animation,
        // ignore: avoid_redundant_argument_values
        removeOnFinish: false,
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

    test('removeOnFinish is false and animation#loop is true', () {
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
      final component = SpriteAnimationComponent(
        animation: animation,
        // ignore: avoid_redundant_argument_values
        removeOnFinish: false,
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

    test("component isn't removed if it is not playing", () {
      final game = FlameGame();
      final animation = SpriteAnimation.spriteList(
        [
          Sprite(image),
          Sprite(image),
        ],
        stepTime: 1,
        loop: false,
      );
      final component = SpriteAnimationComponent(
        animation: animation,
        removeOnFinish: true,
        playing: false,
      );

      game.onGameResize(size);
      game.add(component);

      // runs a cycle to add the component
      game.update(0.1);
      expect(component.shouldRemove, false);
      expect(game.children.length, 1);

      game.update(2);
      expect(component.shouldRemove, false);

      // runs a cycle to potentially remove the component
      game.update(0.1);
      expect(game.children.length, 1);
    });
  });

  group('SpriteAnimation timing of animation frames', () {
    test('Last animation frame is not skipped', () {
      // See https://github.com/flame-engine/flame/issues/895
      final game = FlameGame();
      // Non-looping animation, with the expected total duration of 0.500 s
      final animation = SpriteAnimation.spriteList(
        List.filled(5, Sprite(image)),
        stepTime: 0.1,
        loop: false,
      );
      var callbackInvoked = 0;
      animation.onComplete = () {
        callbackInvoked++;
      };
      final component = SpriteAnimationComponent(animation: animation);
      game.onGameResize(size);
      game.add(component);
      game.update(0.01);
      expect(animation.currentIndex, 0);
      game.update(0.1);
      expect(animation.currentIndex, 1);
      game.update(0.3);
      expect(animation.currentIndex, 4);
      game.update(0.089);
      // At this point we're still on the last frame, which has
      // almost finished. Total clock time = 0.499 s
      expect(animation.currentIndex, 4);
      expect(animation.clock, closeTo(0.099, 1e-10));
      expect(animation.done(), false);
      expect(callbackInvoked, 0);
      // This last tick moves the total clock to 0.5001 s,
      // completing the last animation frame.
      game.update(0.0011);
      expect(callbackInvoked, 1);
      expect(animation.currentIndex, 4);
      expect(animation.done(), true);
      // Now move the timer forward again, and verify that the callback won't be
      // invoked multiple times.
      for (var i = 0; i < 10; i++) {
        game.update(1);
      }
      expect(callbackInvoked, 1);
      expect(animation.currentIndex, 4);
      expect(animation.done(), true);
      // Lastly, let's reset the animation and see if it still works properly
      callbackInvoked = 0;
      animation.reset();
      expect(animation.currentIndex, 0);
      expect(animation.done(), false);
      game.update(100);
      expect(callbackInvoked, 1);
      expect(animation.currentIndex, 4);
      expect(animation.done(), true);
    });
  });
}
