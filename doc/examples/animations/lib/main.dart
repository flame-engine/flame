import 'package:flame/gestures.dart';
import 'package:flutter/gestures.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/animation.dart' as flame_animation;
import 'package:flame/components/animation_component.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.images.loadAll(['creature.png', 'chopper.png']);

  final Size size = await Flame.util.initialDimensions();
  final game = MyGame(size);
  runApp(game.widget);
}

class MyGame extends BaseGame with TapDetector {
  final animation = flame_animation.Animation.sequenced(
    'chopper.png',
    4,
    textureWidth: 48,
    textureHeight: 48,
    stepTime: 0.15,
    loop: true,
  );

  void addAnimation(double x, double y) {
    const textureWidth = 291.0;
    const textureHeight = 178.0;
    final animationComponent = AnimationComponent.sequenced(
      291,
      178,
      'creature.png',
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
  }

  @override
  void onTapDown(TapDownDetails evt) {
    addAnimation(evt.globalPosition.dx, evt.globalPosition.dy);
  }

  MyGame(Size screenSize) {
    size = screenSize;

    const s = 100.0;
    final animationComponent = AnimationComponent(s, s, animation);
    animationComponent.x = size.width / 2 - s;
    animationComponent.y = s;

    final reversedAnimationComponent =
        AnimationComponent(s, s, animation.reversed());
    reversedAnimationComponent.x = size.width / 2;
    reversedAnimationComponent.y = s;

    add(animationComponent);
    add(reversedAnimationComponent);
  }
}
