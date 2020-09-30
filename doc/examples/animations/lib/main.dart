import 'package:flame/gestures.dart';
import 'package:flutter/gestures.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/sprite_animation.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flutter/material.dart' hide Image;
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Vector2 size = await Flame.util.initialDimensions();
  final game = MyGame(size);
  runApp(game.widget);
}

class MyGame extends BaseGame with TapDetector {
  Image chopper;
  Image creature;
  SpriteAnimation animation;

  @override
  Future<void> onLoad() async {
    chopper = await images.load('chopper.png');
    creature = await images.load('creature.png');

    animation = SpriteAnimation.sequenced(
      chopper,
      4,
      textureWidth: 48,
      textureHeight: 48,
      stepTime: 0.15,
      loop: true,
    );
  }

  void addAnimation(double x, double y) {
    const textureWidth = 291.0;
    const textureHeight = 178.0;

    final animationComponent = SpriteAnimationComponent.sequenced(
      291,
      178,
      creature,
      18,
      amountPerRow: 10,
      textureWidth: textureWidth,
      textureHeight: textureHeight,
      stepTime: 0.15,
      loop: false,
      destroyOnFinish: true,
    );

    animationComponent.x = x - textureWidth / 2;
    animationComponent.y = y - textureHeight / 2;

    add(animationComponent);

    const s = 100.0;
    final animationComponent2 = SpriteAnimationComponent(s, s, animation);
    animationComponent2.x = size.width / 2 - s;
    animationComponent2.y = s;

    final reversedAnimationComponent = SpriteAnimationComponent(
      s,
      s,
      animation.reversed(),
    );
    reversedAnimationComponent.x = size.x / 2;
    reversedAnimationComponent.y = s;

    add(animationComponent2);
    add(reversedAnimationComponent);
  }

  @override
  void onTapDown(TapDownDetails evt) {
    addAnimation(evt.globalPosition.dx, evt.globalPosition.dy);
  }

  MyGame(Vector2 screenSize) {
    size = screenSize;
  }
}
