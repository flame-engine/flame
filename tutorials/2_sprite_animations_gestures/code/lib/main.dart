import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

void main() {
  final myGame = MyGame();
  runApp(GameWidget(game: myGame));
}

class MyGame extends Game with TapDetector {
  late SpriteAnimation runningRobot;
  late Sprite pressedButton;
  late Sprite unpressedButton;

  bool isPressed = false;

  final buttonPosition = Vector2(200, 120);
  final buttonSize = Vector2(120, 30);

  final robotPosition = Vector2(240, 50);
  final robotSize = Vector2(48, 60);

  @override
  Future<void> onLoad() async {
    runningRobot = await loadSpriteAnimation(
      'robot.png',
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.1,
        textureSize: Vector2(16, 18),
      ),
    );

    unpressedButton = await loadSprite(
      'buttons.png',
      srcPosition: Vector2.zero(),
      srcSize: Vector2(60, 20),
    );

    pressedButton = await loadSprite(
      'buttons.png',
      srcPosition: Vector2(0, 20),
      srcSize: Vector2(60, 20),
    );
  }

  @override
  void onTapDown(TapDownInfo event) {
    final buttonArea = buttonPosition & buttonSize;

    isPressed = buttonArea.contains(event.eventPosition.game.toOffset());
  }

  @override
  void onTapUp(TapUpInfo event) {
    isPressed = false;
  }

  @override
  void onTapCancel() {
    isPressed = false;
  }

  @override
  void update(double dt) {
    if (isPressed) {
      runningRobot.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    runningRobot
        .getSprite()
        .render(canvas, position: robotPosition, size: robotSize);

    final button = isPressed ? pressedButton : unpressedButton;
    button.render(canvas, position: buttonPosition, size: buttonSize);
  }

  @override
  Color backgroundColor() => const Color(0xFF222222);
}
