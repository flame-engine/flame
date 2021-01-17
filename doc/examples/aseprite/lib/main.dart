import 'package:flame/game.dart';
import 'package:flame/sprite_animation.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

class MyGame extends BaseGame {
  @override
  Future<void> onLoad() async {
    final image = await images.load('chopper.png');
    final jsonData = await assets.readJson('chopper.json');
    final animation = SpriteAnimation.fromAsepriteData(
      image,
      jsonData,
    );
    final spriteSize = Vector2.all(200);
    final animationComponent =
        SpriteAnimationComponent.fromSpriteAnimation(spriteSize, animation)
          ..position = size / 2 - Vector2.all(100);

    add(animationComponent);
  }
}
