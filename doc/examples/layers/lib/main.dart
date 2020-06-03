import 'package:flutter/material.dart' hide Animation;
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame/animation.dart';
import 'package:flame/layer.dart';
import 'package:flame/flame.dart';

import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Flame.util.fullScreen();

  final sprite = await Sprite.loadSprite('sprites.png');

  await Flame.images.load('bomb_ptero.png');
  final spriteSheet = SpriteSheet(
      imageName: 'bomb_ptero.png',
      textureWidth: 48,
      textureHeight: 32,
      columns: 4,
      rows: 1);

  final animation = spriteSheet.createAnimation(0, stepTime: 0.2, to: 3);
  runApp(LayerGame(sprite, animation).widget);
}

class LayerGame extends Game {
  Sprite sprite;
  Animation animation;
  Layer layerWithDropShadow;
  Layer animationLayerWithDropShadow;
  Layer layerWithoutDropShadow;

  LayerGame(this.sprite, this.animation) {
    layerWithDropShadow = Layer()..preProcessors.add(ShadowProcessor());
    animationLayerWithDropShadow = Layer()
      ..preProcessors.add(ShadowProcessor());

    layerWithoutDropShadow = Layer();

    layerWithoutDropShadow.beginRendering();
    layerWithDropShadow.beginRendering();

    sprite.renderRect(
        layerWithoutDropShadow.canvas, const Rect.fromLTWH(50, 50, 200, 200));
    sprite.renderRect(
        layerWithDropShadow.canvas, const Rect.fromLTWH(50, 50, 200, 200));

    layerWithoutDropShadow.finishRendering();
    layerWithDropShadow.finishRendering();
  }

  @override
  void update(double dt) {
    animation.update(dt);
  }

  @override
  void render(Canvas canvas) {
    layerWithoutDropShadow.render(canvas);
    layerWithDropShadow.render(canvas, y: 250);

    animationLayerWithDropShadow.beginRendering();
    animation.getSprite().renderRect(animationLayerWithDropShadow.canvas,
        const Rect.fromLTWH(0, 0, 150, 100));
    animationLayerWithDropShadow
      ..finishRendering()
      ..render(canvas, x: 100, y: 600);
  }

  @override
  Color backgroundColor() => const Color(0xFF38607C);
}
