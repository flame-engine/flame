import 'dart:ui';

import 'package:examples/stories/games/trex/background/horizon.dart';
import 'package:examples/stories/games/trex/game_over.dart';
import 'package:examples/stories/games/trex/player.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum GameState { playing, intro, gameOver }

class TRexGame extends FlameGame
    with KeyboardEvents, TapDetector, HasCollisionDetection {
  static const String description = '''
    A game similar to the game in chrome that you get to play while offline.
    Press space or tap/click the screen to jump, the more obstacles you manage
    to survive, the more points you get.
  ''';

  late final Image spriteImage;

  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);

  late final player = Player();
  late final horizon = Horizon();
  late final gameOverPanel = GameOverPanel();
  late final TextComponent scoreText;

  late int _score;
  int get score => _score;
  set score(int newScore) {
    _score = newScore;
    scoreText.text = 'Score:$score';
  }

  @override
  Future<void> onLoad() async {
    spriteImage = await Flame.images.load('trex.png');
    add(horizon);
    add(player);
    add(gameOverPanel);

    final textStyle = GoogleFonts.pressStart2p(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade700,
    );
    final textPaint = TextPaint(style: textStyle);
    add(
      scoreText = TextComponent(
        position: Vector2(20, 20),
        textRenderer: textPaint,
      )..positionType = PositionType.viewport,
    );
    score = 0;
  }

  GameState state = GameState.intro;
  double currentSpeed = 0.0;
  double timePlaying = 0.0;

  final double acceleration = 10;
  final double maxSpeed = 2500.0;
  final double startSpeed = 600;

  bool get isPlaying => state == GameState.playing;
  bool get isGameOver => state == GameState.gameOver;
  bool get isIntro => state == GameState.intro;

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (keysPressed.contains(LogicalKeyboardKey.enter) ||
        keysPressed.contains(LogicalKeyboardKey.space)) {
      onAction();
    }
    return KeyEventResult.handled;
  }

  @override
  void onTapDown(TapDownInfo info) {
    onAction();
  }

  void onAction() {
    if (isGameOver || isIntro) {
      restart();
      return;
    }
    player.jump(currentSpeed);
  }

  void gameOver() {
    gameOverPanel.visible = true;
    state = GameState.gameOver;
    player.current = PlayerState.crashed;
    currentSpeed = 0.0;
  }

  void restart() {
    state = GameState.playing;
    player.reset();
    horizon.reset();
    currentSpeed = startSpeed;
    gameOverPanel.visible = false;
    timePlaying = 0.0;
    score = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      return;
    }

    if (isPlaying) {
      timePlaying += dt;

      if (currentSpeed < maxSpeed) {
        currentSpeed += acceleration * dt;
      }
    }
  }
}
