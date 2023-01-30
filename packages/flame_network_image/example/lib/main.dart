import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_network_image/flame_network_image.dart';
import 'package:flutter/material.dart' hide Image;

void main() {
  runApp(GameWidget.controlled(gameFactory: MyGame.new));
}

class MyGame extends FlameGame with TapDetector {
  final networkImages = FlameNetworkImages();
  late Image charSprite;

  @override
  Future<void> onLoad() async {
    charSprite = await networkImages.load(
      'https://examples.flame-engine.org/assets/assets/images/bomb_ptero.png',
    );
  }

  @override
  bool onTapUp(TapUpInfo info) {
    add(
      SpriteAnimationComponent.fromFrameData(
        charSprite,
        SpriteAnimationData.sequenced(
          textureSize: Vector2(48, 32),
          amount: 4,
          stepTime: .2,
        ),
        size: Vector2(100, 50),
        anchor: Anchor.center,
        position: info.eventPosition.game,
      ),
    );

    return true;
  }
}
