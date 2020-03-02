import 'dart:ui';
import 'package:flutter/material.dart' hide Animation, Image;

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/animation.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';

void main() async {
  final Size size = await Flame.util.initialDimensions();

  await Flame.images.load('spritesheet.png');

  final game = MyGame(size);
  runApp(game.widget);
}

class MyGame extends BaseGame {
  MyGame(Size screenSize) {
    size = screenSize;

    final Image spritesheet = Flame.images.fromCache('spritesheet.png');
    const spriteWidth  = 16;
    const spriteHeight = 18;

    final vampireAnimation = Animation.fromImage(
      spritesheet,
      frameWidth:  spriteWidth,
      frameHeight: spriteHeight,
      frameCount:  8,
      stepTime:    0.1,
    );
    final ghostAnimation = Animation.fromImage(
      spritesheet,
      frameY:      spriteHeight * 1,
      frameWidth:  spriteWidth,
      frameHeight: spriteHeight,
      frameCount:  8,
      stepTime:    0.1,
    );

    final vampireComponent = AnimationComponent(
      vampireAnimation,
      width:  80,
      height: 90,
      x:      150,
      y:      100,
    );
    final ghostComponent = AnimationComponent(
      ghostAnimation,
      width:  80,
      height: 90,
      x:      150,
      y:      220,
    );

    add(vampireComponent);
    add(ghostComponent);

    // Some plain sprites
    final vampireSpriteComponent = SpriteComponent(
      Sprite.fromImage(
        spritesheet,
        width:  spriteWidth,
        height: spriteHeight,
      ),
      width:  80,
      height: 90,
      x:      50,
      y:      100,
    );

    final ghostSpriteComponent = SpriteComponent(
      Sprite.fromImage(
        spritesheet,
        x:      spriteWidth  * 0,
        y:      spriteHeight * 1,
        width:  spriteWidth,
        height: spriteHeight,
      ),
      width:  80,
      height: 90,
      x:      50,
      y:      220,
    );

    add(vampireSpriteComponent);
    add(ghostSpriteComponent);
  }
}
