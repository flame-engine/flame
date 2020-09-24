import 'package:flutter/material.dart' hide Animation;
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/layer/layer.dart';
import 'package:flame/flame.dart';

import 'dart:ui';

void main() async {
  Flame.initializeWidget();

  await Flame.util.fullScreen();

  runApp(LayerGame().widget);
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
  Layer gameLayer;
  Layer backgroundLayer;

  @override
  Future<void> onLoad() async {
    final playerSprite = Sprite(await images.load('player.png'));
    final enemySprite = Sprite(await images.load('enemy.png'));
    final backgroundSprite = Sprite(await images.load('background.png'));

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
