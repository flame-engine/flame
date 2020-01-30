import 'dart:ui';
import 'package:flame/gestures.dart';
import 'package:flame/game.dart';
import 'package:flame/components/flare_component.dart';
import 'package:flame/text_config.dart';
import 'package:flame/position.dart';
import 'package:flame/palette.dart';

import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final game = MyGame();
  runApp(game.widget);
}

class MyGame extends BaseGame with TapDetector, DoubleTapDetector {
  final TextConfig fpsTextConfig = TextConfig(color: BasicPalette.white.color);

  final paint = Paint()..color = const Color(0xFFE5E5E5E5);
  final List<String> _animations = ['Stand', 'Wave', 'Jump', 'Dance'];
  int _currentAnimation = 0;
  FlareComponent flareComponent;

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

  @override
  void onDoubleTap() {
    flareComponent.width += 10;
    flareComponent.height += 10;

    flareComponent.x -= 10;
    flareComponent.y -= 10;
  }

  void cycleAnimation() {
    if (_currentAnimation == 3) {
      _currentAnimation = 0;
    } else {
      _currentAnimation++;
    }
    flareComponent.updateAnimation(_animations[_currentAnimation]);
  }

  void _start() async {
    flareComponent = FlareComponent('assets/Bob_Minion.flr', 'Stand', 306, 228);
    flareComponent.x = 50;
    flareComponent.y = 240;
    add(flareComponent);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (debugMode()) {
      fpsTextConfig.render(canvas, fps(120).toString(), Position(0, 10));
    }
  }
}
