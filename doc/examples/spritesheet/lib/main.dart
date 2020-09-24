import 'package:flame/extensions/vector2.dart';
import 'package:flutter/material.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/spritesheet.dart';
import 'package:dashbook/dashbook.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final spriteSheet = SpriteSheet(
    imageName: 'spritesheet.png',
    textureWidth: 16,
    textureHeight: 18,
    columns: 11,
    rows: 2,
  );

  final spriteSheetFromImage = SpriteSheet.fromImage(
    image: await Flame.images.load('spritesheet.png'),
    textureWidth: 16,
    textureHeight: 18,
    columns: 11,
    rows: 2,
  );

  final dashbook = Dashbook();

  dashbook
      .storiesOf('SpriteSheet')
      .add('defaut', (_) => GameWrapper(MyGame(spriteSheet)))
      .add('fromImage', (_) => GameWrapper(MyGame(spriteSheetFromImage)));

  runApp(dashbook);
}

class GameWrapper extends StatelessWidget {
  final Game game;

  GameWrapper(this.game);

  @override
  Widget build(_) {
    return Container(
      width: 400,
      height: 400,
      child: game.widget,
    );
  }
}

class MyGame extends BaseGame {
  MyGame(SpriteSheet spriteSheet) {
    final vampireAnimation =
        spriteSheet.createAnimation(0, stepTime: 0.1, to: 7);
    final ghostAnimation = spriteSheet.createAnimation(1, stepTime: 0.1, to: 7);
    final spriteSize = Vector2(80, 90);

    final vampireComponent = SpriteAnimationComponent(spriteSize, vampireAnimation)
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
