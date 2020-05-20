import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Size size = await Flame.util.initialDimensions();
  final game = MyGame(size);
  runApp(game.widget);
}

class MyGame extends BaseGame {
  MyGame(Size screenSize) {
    size = screenSize;

    final spritesheet = SpriteSheet(
      imageName: 'spritesheet.png',
      textureWidth: 16,
      textureHeight: 18,
      columns: 11,
      rows: 2,
    );

    final vampireAnimation =
        spritesheet.createAnimation(0, stepTime: 0.1, to: 7);
    final ghostAnimation = spritesheet.createAnimation(1, stepTime: 0.1, to: 7);

    final vampireComponent = AnimationComponent(80, 90, vampireAnimation);
    vampireComponent.x = 150;
    vampireComponent.y = 100;

    final ghostComponent = AnimationComponent(80, 90, ghostAnimation);
    ghostComponent.x = 150;
    ghostComponent.y = 220;

    add(vampireComponent);
    add(ghostComponent);

    // Some plain sprites
    final vampireSpriteComponent =
        SpriteComponent.fromSprite(80, 90, spritesheet.getSprite(0, 0));
    vampireSpriteComponent.x = 50;
    vampireSpriteComponent.y = 100;

    final ghostSpriteComponent =
        SpriteComponent.fromSprite(80, 90, spritesheet.getSprite(1, 0));
    ghostSpriteComponent.x = 50;
    ghostSpriteComponent.y = 220;

    add(vampireSpriteComponent);
    add(ghostSpriteComponent);
  }
}
