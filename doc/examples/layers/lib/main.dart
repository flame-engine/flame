import 'package:flutter/material.dart' hide Animation;
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/layer/layer.dart';
import 'package:flame/flame.dart';

import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Flame.util.fullScreen();

  final playerSprite = await Sprite.loadSprite('player.png');
  final enemySprite = await Sprite.loadSprite('enemy.png');
  final backgroundSprite = await Sprite.loadSprite('background.png');

  runApp(LayerGame(playerSprite, enemySprite, backgroundSprite).widget);
}

class GameLayer extends DynamicLayer {
  final Sprite playerSprite;
  final Sprite enemySprite;

  GameLayer(this.playerSprite, this.enemySprite) {
    preProcessors.add(ShadowProcessor());
  }

  @override
  void drawLayer() {
    playerSprite.renderRect(
      canvas,
      const Rect.fromLTWH(50, 50, 150, 150),
    );
    enemySprite.renderRect(
      canvas,
      const Rect.fromLTWH(250, 150, 100, 50),
    );
  }
}

class BackgroundLayer extends PreRenderedLayer {
  final Sprite sprite;

  BackgroundLayer(this.sprite) {
    preProcessors.add(ShadowProcessor());
  }

  @override
  void drawLayer() {
    sprite.renderRect(
      canvas,
      const Rect.fromLTWH(50, 200, 300, 150),
    );
  }
}

class LayerGame extends Game {
  Sprite playerSprite;
  Sprite enemySprite;
  Sprite backgroundSprite;

  Layer gameLayer;
  Layer backgroundLayer;

  LayerGame(this.playerSprite, this.enemySprite, this.backgroundSprite) {
    gameLayer = GameLayer(playerSprite, enemySprite);
    backgroundLayer = BackgroundLayer(backgroundSprite);
  }

  @override
  void update(double dt) {}

  @override
  void render(Canvas canvas) {
    gameLayer.render(canvas);
    backgroundLayer.render(canvas);
  }

  @override
  Color backgroundColor() => const Color(0xFF38607C);
}
