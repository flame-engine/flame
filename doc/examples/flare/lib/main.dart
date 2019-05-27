import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/flare_animation.dart';
import 'package:flame/text_config.dart';
import 'package:flame/position.dart';

import 'package:flutter/material.dart';

void main() {
  final game = MyGame();
  runApp(game.widget);

  Flame.util.addGestureRecognizer(TapGestureRecognizer()
    ..onTapDown = (TapDownDetails evt) {
      game.cycleAnimation();
    });
}

class MyGame extends BaseGame {
  final TextConfig fpsTextConfig = TextConfig(color: const Color(0xFFFFFFFF));

  final paint = Paint()..color = Color(0xFFe5e5e5e5);
  List<String> _animations = ["Stand", "Wave", "Jump", "Dance"];
  int _currentAnimation = 0;

  FlareAnimation flareAnimation;
  FlareAnimation flareAnimation2;
  FlareAnimation flareAnimation3;
  FlareAnimation flareAnimation4;
  bool loaded = false;

  MyGame() {
    _start();
  }

  @override
  bool debugMode() => true;

  void cycleAnimation() {
    if (_currentAnimation == 3) {
      _currentAnimation = 0;
    } else {
      _currentAnimation++;
    }

    flareAnimation.updateAnimation(_animations[_currentAnimation]);
  }

  void _start() async {
    flareAnimation = await FlareAnimation.load("assets/Bob_Minion.flr");
    flareAnimation.updateAnimation("Stand");

    flareAnimation.x = 50;
    flareAnimation.y = 50;

    flareAnimation.width = 306;
    flareAnimation.height = 228;

    // Second animation
    flareAnimation2 = await FlareAnimation.load("assets/Bob_Minion.flr");
    flareAnimation2.updateAnimation("Wave");

    flareAnimation2.x = 50;
    flareAnimation2.y = 240;

    flareAnimation2.width = 306;
    flareAnimation2.height = 228;

    // Third animation
    flareAnimation3 = await FlareAnimation.load("assets/Bob_Minion.flr");
    flareAnimation3.updateAnimation("Jump");

    flareAnimation3.x = 50;
    flareAnimation3.y = 400;

    flareAnimation3.width = 306;
    flareAnimation3.height = 228;

    // Third animation
    flareAnimation4 = await FlareAnimation.load("assets/Bob_Minion.flr");
    flareAnimation4.updateAnimation("Dance");

    flareAnimation4.x = 50;
    flareAnimation4.y = 550;

    flareAnimation4.width = 306;
    flareAnimation4.height = 228;

    loaded = true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (loaded) {
      canvas.drawRect(
          Rect.fromLTWH(flareAnimation.x, flareAnimation.y,
              flareAnimation.width, flareAnimation.height),
          paint);
      flareAnimation.render(canvas);

      flareAnimation2.render(canvas);
      flareAnimation3.render(canvas);
      flareAnimation4.render(canvas);
    }

    if (debugMode()) {
      fpsTextConfig.render(canvas, fps(120).toString(), Position(0, 10));
    }
  }

  @override
  void update(double dt) {
    if (loaded) {
      flareAnimation.update(dt);
      flareAnimation2.update(dt);
      flareAnimation3.update(dt);
      flareAnimation4.update(dt);
    }
  }
}
