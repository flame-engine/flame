import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:trex_game/background/horizon.dart';
import 'package:trex_game/game_over.dart';
import 'package:trex_game/player.dart';

enum GameState { playing, intro, gameOver }

class TRexGame extends FlameGame
    with KeyboardEvents, TapCallbacks, HasCollisionDetection {
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

  int _score = 0;
  int _highScore = 0;
  int get score => _score;
  set score(int newScore) {
    _score = newScore;
    scoreText.text = '${scoreString(_score)}  HI ${scoreString(_highScore)}';
  }

  String scoreString(int score) => score.toString().padLeft(5, '0');

  /// Used for score calculation
  double _distanceTraveled = 0;

  @override
  Future<void> onLoad() async {
    spriteImage = await Flame.images.load('trex.png');
    add(horizon);
    add(player);
    add(gameOverPanel);

    const chars = '0123456789HI ';
    final renderer = SpriteFontRenderer.fromFont(
      SpriteFont(
        source: spriteImage,
        size: 23,
        ascent: 23,
        glyphs: [
          for (var i = 0; i < chars.length; i++)
            Glyph(chars[i], left: 954.0 + 20 * i, top: 0, width: 20),
        ],
      ),
      letterSpacing: 2,
    );
    add(
      scoreText = TextComponent(
        position: Vector2(20, 20),
        textRenderer: renderer,
      ),
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
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (keysPressed.contains(LogicalKeyboardKey.enter) ||
        keysPressed.contains(LogicalKeyboardKey.space)) {
      onAction();
    }
    return KeyEventResult.handled;
  }

  @override
  void onTapDown(TapDownEvent event) {
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
    if (score > _highScore) {
      _highScore = score;
    }
    score = 0;
    _distanceTraveled = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      return;
    }

    if (isPlaying) {
      timePlaying += dt;
      _distanceTraveled += dt * currentSpeed;
      score = _distanceTraveled ~/ 50;

      if (currentSpeed < maxSpeed) {
        currentSpeed += acceleration * dt;
      }
    }
  }
}
