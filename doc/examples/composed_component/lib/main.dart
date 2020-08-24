import 'dart:ui';

import 'package:flame/animation.dart' as flame;
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/composed_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() async {
  await Flame.init(fullScreen: true, orientations: Flame.landscape());
  final size = await Flame.util.initialDimensions();
  runApp(MyGame(size).widget);
}

class MyGame extends BaseGame with HasTapableComponents {
  MyGame(Size size) {
    resize(size);
    add(Composed());
  }

  void log(String message) {
    print(message);
  }

  @override
  Color backgroundColor() => const Color(0xffcccccc);
}

class Composed extends Component
    with HasGameRef<MyGame>, Tapable, ComposedComponent {
  @override
  void onMount() {
    gameRef.log("Composed call MyGame log method");
    add(
      TextComponent("ComposedComponent")
        ..x = 100
        ..y = 100,
    );
    add(
      AnimationComponent(
          48,
          48,
          flame.Animation.sequenced(
            'chopper.png',
            4,
            textureWidth: 48,
            textureHeight: 48,
            stepTime: 0.15,
            loop: true,
          ))
        ..x = 200
        ..y = 200,
    );
  }

  @override
  Rect toRect() {
    return Rect.zero;
  }
}
