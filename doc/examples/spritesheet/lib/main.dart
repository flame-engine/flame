import 'package:flame/extensions/vector2.dart';
import 'package:flutter/material.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/game.dart';
import 'package:flame/spritesheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyGame().widget);
}

class MyGame extends BaseGame {
  @override
  Future<void> onLoad() async {
    final spriteSheet = SpriteSheet(
      image: await images.load('spritesheet.png'),
      textureWidth: 16,
      textureHeight: 18,
      columns: 11,
      rows: 2,
    );

    final vampireAnimation =
        spriteSheet.createAnimation(0, stepTime: 0.1, to: 7);
    final ghostAnimation = spriteSheet.createAnimation(1, stepTime: 0.1, to: 7);
    final spriteSize = Vector2(80, 90);

    final vampireComponent =
        SpriteAnimationComponent(spriteSize, vampireAnimation)
          ..x = 150
          ..y = 100;

    final ghostComponent = SpriteAnimationComponent(spriteSize, ghostAnimation)
      ..x = 150
      ..y = 220;

    add(vampireComponent);
    add(ghostComponent);

    // Some plain sprites
    final vampireSpriteComponent =
        SpriteComponent.fromSprite(spriteSize, spriteSheet.getSprite(0, 0))
          ..x = 50
          ..y = 100;

    final ghostSpriteComponent =
        SpriteComponent.fromSprite(spriteSize, spriteSheet.getSprite(1, 0))
          ..x = 50
          ..y = 220;

    add(vampireSpriteComponent);
    add(ghostSpriteComponent);
  }
}
