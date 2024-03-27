import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flutter/material.dart';

void main() {
  final myGame = MyGame();
  runApp(
    GameWidget(
      game: myGame,
    ),
  );
}

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load the atlasMap.
    final atlas = await atlasFromAssets('atlas_map.atlas');

    // Get a list of sprites ordered by their index
    final walkingSprites = atlas.findSpritesByName('robot_walk');

    // Create animation with the list of sprites
    final walkingAnimation = SpriteAnimation.spriteList(
      walkingSprites,
      stepTime: 0.1,
    );

    // Get individual sprites by name
    final jumpSprite = atlas.findSpriteByName('robot_jump')!;
    final fallSprite = atlas.findSpriteByName('robot_fall')!;
    final idleSprite = atlas.findSpriteByName('robot_idle')!;

    // Get the list of all sprites in the sprite sheet
    final allSprites = atlas.sprites; // ignore: unused_local_variable

    add(
      SpriteComponent(
        sprite: jumpSprite,
        position: Vector2(200, 100),
        size: Vector2(72, 96),
      ),
    );

    add(
      SpriteComponent(
        sprite: fallSprite,
        position: Vector2(300, 100),
        size: Vector2(72, 96),
      ),
    );

    add(
      SpriteComponent(
        sprite: idleSprite,
        position: Vector2(400, 100),
        size: Vector2(72, 96),
      ),
    );

    add(
      SpriteAnimationComponent(
        animation: walkingAnimation,
        position: Vector2(300, 200),
        size: Vector2(72, 96),
      ),
    );
  }
}
