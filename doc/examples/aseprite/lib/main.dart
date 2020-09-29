import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite_animation.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Size size = await Flame.util.initialDimensions();
  runApp(MyGame(size).widget);
}

class MyGame extends BaseGame {
  MyGame(Size screenSize) {
    size = screenSize;
  }

  @override
  Future<void> onLoad() async {
    final image = await images.load('chopper.png');
    final animation = await SpriteAnimation.fromAsepriteData(
      image,
      'chopper.json',
    );

    final animationComponent = SpriteAnimationComponent(200, 200, animation);

    animationComponent.x = (size.width / 2) - 100;
    animationComponent.y = (size.height / 2) - 100;

    add(animationComponent);
  }
}
