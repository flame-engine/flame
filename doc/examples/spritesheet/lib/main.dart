import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

class MyGame extends BaseGame {
  @override
  Future<void> onLoad() async {
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
      position: Vector2(150, 100),
      size: spriteSize,
      animation: vampireAnimation,
    );

    final ghostComponent = SpriteAnimationComponent(
      position: Vector2(150, 220),
      size: spriteSize,
      animation: ghostAnimation,
    );

    add(vampireComponent);
    add(ghostComponent);

    // Some plain sprites
    final vampireSpriteComponent = SpriteComponent(
      position: Vector2(50, 100),
      size: spriteSize,
      sprite: spriteSheet.getSprite(0, 0),
    );

    final ghostSpriteComponent = SpriteComponent(
      position: Vector2(50, 220),
      size: spriteSize,
      sprite: spriteSheet.getSprite(1, 0),
    );

    add(vampireSpriteComponent);
    add(ghostSpriteComponent);
  }
}
