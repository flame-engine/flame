import 'package:flutter/gestures.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/animation.dart' as flame_animation;
import 'package:flame/components/animation_component.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Size size = await Flame.util.initialDimensions();
  await Flame.images.loadAll(['creture.png', 'chopper.png']);
  final game = MyGame(size);
  runApp(game.widget);
}

class MyGame extends BaseGame {
  final animation = flame_animation.Animation.sequenced(
    'chopper.png',
    4,
    textureWidth: 48,
    textureHeight: 48,
    stepTime: 0.15,
  );

  void addAnimation() {
    final animationComponent = AnimationComponent.sequenced(
      291,
      178,
      'creture.png',
      18,
      amountPerRow: 10,
      textureWidth: 291,
      textureHeight: 178,
      stepTime: 0.15,
      loop: false,
      destroyOnFinish: true,
    );
    animationComponent.x = (size.width - 291) / 2;
    animationComponent.y = 250;

    add(animationComponent);
  }

  @override
  void onTapDown(TapDownDetails details) {
    super.onTapDown(details);
    addAnimation();
  }

  MyGame(Size screenSize) {
    size = screenSize;

    const s = 100.0;
    const y = 150.0;
    final m = (size.width - 2 * s) / 3;

    final animationComponent = AnimationComponent(s, s, animation);
    animationComponent.x = m;
    animationComponent.y = y;
    add(animationComponent);
    
    final reversedAnimationComponent = AnimationComponent(s, s, animation.reversed());
    reversedAnimationComponent.x = 2 * m + s;
    reversedAnimationComponent.y = y;
    add(reversedAnimationComponent);
  }
}
