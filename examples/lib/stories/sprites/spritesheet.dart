import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

class SpritesheetGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final spriteSheet = SpriteSheet(
      image: await images.load('spritesheet.png'),
      srcSize: Vector2(16.0, 18.0),
    );

    final vampireAnimation =
        spriteSheet.createAnimation(row: 0, stepTime: 0.1, to: 7);
    final ghostAnimation =
        spriteSheet.createAnimation(row: 1, stepTime: 0.1, to: 7);
    final spriteSize = Vector2(80.0, 90.0);

    final vampireComponent = SpriteAnimationComponent(
      animation: vampireAnimation,
      position: Vector2(150, 100),
      size: spriteSize,
    );

    final ghostComponent = SpriteAnimationComponent(
      animation: ghostAnimation,
      position: Vector2(150, 220),
      size: spriteSize,
    );

    add(vampireComponent);
    add(ghostComponent);

    // Some plain sprites
    final vampireSpriteComponent = SpriteComponent(
      sprite: spriteSheet.getSprite(0, 0),
      position: Vector2(50, 100),
      size: spriteSize,
    );

    final ghostSpriteComponent = SpriteComponent(
      sprite: spriteSheet.getSprite(1, 0),
      size: spriteSize,
      position: Vector2(50, 220),
    );

    add(vampireSpriteComponent);
    add(ghostSpriteComponent);
  }
}
