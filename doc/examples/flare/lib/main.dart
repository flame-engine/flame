import 'dart:ui';
import 'dart:math';
import 'package:flame/gestures.dart';
import 'package:flame/game.dart';
import 'package:flame/flare_animation.dart';
import 'package:flame/components/flare_component.dart';
import 'package:flame/text_config.dart';
import 'package:flame/position.dart';

import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final game = MyGame();
  runApp(game.widget);
}

class MyGame extends BaseGame with TapDetector {
  final TextConfig fpsTextConfig =
      const TextConfig(color: const Color(0xFFFFFFFF));

  final paint = Paint()..color = const Color(0xFFE5E5E5E5);
  final List<String> _animations = ["Stand", "Wave", "Jump", "Dance"];
  int _currentAnimation = 0;

  FlareAnimation flareAnimation;
  bool loaded = false;

  MyGame() {
    _start();
  }

  @override
  bool debugMode() => true;

  @override
  void onTap() {
    cycleAnimation();
  }

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

    flareAnimation.width = 306;
    flareAnimation.height = 228;
    flareAnimation.angle = (90 * (pi / 180.0));

    final flareAnimation2 =
        FlareComponent("assets/Bob_Minion.flr", "Wave", 306, 228);
    flareAnimation2.x = 50;
    flareAnimation2.y = 240;
    add(flareAnimation2);

    final flareAnimation3 =
        FlareComponent("assets/Bob_Minion.flr", "Jump", 306, 228);
    flareAnimation3.x = 50;
    flareAnimation3.y = 400;
    add(flareAnimation3);

    final flareAnimation4 =
        FlareComponent("assets/Bob_Minion.flr", "Dance", 306, 228);
    flareAnimation4.x = 50;
    flareAnimation4.y = 550;
    add(flareAnimation4);

    loaded = true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (loaded) {
      canvas.drawRect(
        Rect.fromLTWH(50, 50, flareAnimation.width, flareAnimation.height),
        paint,
      );

      flareAnimation.render(canvas, x: 50, y: 50);
    }

    if (debugMode()) {
      fpsTextConfig.render(canvas, fps(120).toString(), Position(0, 10));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (loaded) {
      flareAnimation.update(dt);
    }
  }
}
