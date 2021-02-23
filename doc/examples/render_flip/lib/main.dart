import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final game = MyGame();
  runApp(
    GameWidget(
      game: game,
    ),
  );
}

class MyGame extends BaseGame {
  @override
  Future<void> onLoad() async {
    final image = await images.load('chopper.png');

    final regular = buildAnimationComponent(image);
    regular.y = 100;
    add(regular);

    final flipX = buildAnimationComponent(image);
    flipX.y = 300;
    flipX.renderFlipX = true;
    add(flipX);

    final flipY = buildAnimationComponent(image);
    flipY.y = 500;
    flipY.renderFlipY = true;
    add(flipY);
  }

  SpriteAnimationComponent buildAnimationComponent(Image image) {
    final ac = SpriteAnimationComponent(
      size: Vector2.all(100),
      animation: buildAnimation(image),
    );
    ac.x = size.x / 2 - ac.x / 2;
    return ac;
  }

  SpriteAnimation buildAnimation(Image image) {
    return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(48),
        stepTime: 0.15,
      ),
    );
  }
}
