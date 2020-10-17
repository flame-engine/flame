import 'package:flame/sprite_animation.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final size = await Flame.util.initialDimensions();
  final game = MyGame(size);
  runApp(game.widget);
}

class MyGame extends BaseGame {
  SpriteAnimation animation;

  @override
  Future<void> onLoad() async {
    final image = await images.load('chopper.png');
    animation = SpriteAnimation.sequenced(
      image,
      4,
      textureSize: Vector2.all(48),
      stepTime: 0.15,
    );

    final regular = buildAnimation();
    regular.y = 100;
    add(regular);

    final flipX = buildAnimation();
    flipX.y = 300;
    flipX.renderFlipX = true;
    add(flipX);

    final flipY = buildAnimation();
    flipY.y = 500;
    flipY.renderFlipY = true;
    add(flipY);
  }

  SpriteAnimationComponent buildAnimation() {
    final ac = SpriteAnimationComponent(Vector2.all(100), animation);
    ac.x = gameSize.x / 2 - ac.x / 2;
    return ac;
  }

  MyGame(Vector2 gameSize) {
    this.gameSize = gameSize;
  }
}
