import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

import '../util/mock_image.dart';

void main() async {
  // Generate a image
  final image = await generateImage();

  final size = Vector2(1.0, 1.0);

  group('SpriteAnimationComponent shouldRemove test', () {
    test('removeOnFinish is true and animation#loop is false', () {
      final game = BaseGame();
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

      game.onResize(size);
      game.add(component);

      // runs a cycle to add the component
      game.update(0.1);
      expect(component.shouldRemove, false);
      expect(game.components.length, 1);

      game.update(2);
      expect(component.shouldRemove, true);

      // runs a cycle to remove the component
      game.update(0.1);
      expect(game.components.length, 0);
    });

    test('removeOnFinish is true and animation#loop is true', () {
      final game = BaseGame();
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

      game.onResize(size);
      game.add(component);

      // runs a cycle to add the component
      game.update(0.1);
      expect(component.shouldRemove, false);
      expect(game.components.length, 1);

      game.update(2);
      expect(component.shouldRemove, false);

      // runs a cycle to remove the component, but failed
      game.update(0.1);
      expect(game.components.length, 1);
    });

    test('removeOnFinish is false and animation#loop is false', () {
      final game = BaseGame();
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

      game.onResize(size);
      game.add(component);

      // runs a cycle to add the component
      game.update(0.1);
      expect(component.shouldRemove, false);
      expect(game.components.length, 1);

      game.update(2);
      expect(component.shouldRemove, false);

      // runs a cycle to remove the component, but failed
      game.update(0.1);
      expect(game.components.length, 1);
    });

    test('removeOnFinish is false and animation#loop is true', () {
      final game = BaseGame();
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

      game.onResize(size);
      game.add(component);

      // runs a cycle to add the component
      game.update(0.1);
      expect(component.shouldRemove, false);
      expect(game.components.length, 1);

      game.update(2);
      expect(component.shouldRemove, false);

      // runs a cycle to remove the component, but failed
      game.update(0.1);
      expect(game.components.length, 1);
    });
  });
}
