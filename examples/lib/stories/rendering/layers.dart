import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/layers.dart';

class GameLayer extends DynamicLayer {
  final Sprite playerSprite;
  final Sprite enemySprite;

  GameLayer(this.playerSprite, this.enemySprite) {
    preProcessors.add(ShadowProcessor());
  }

  @override
  void drawLayer() {
    playerSprite.render(
      canvas,
      position: Vector2.all(50),
      size: Vector2.all(150),
    );
    enemySprite.render(
      canvas,
      position: Vector2(250, 150),
      size: Vector2(100, 50),
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
    sprite.render(
      canvas,
      position: Vector2(50, 200),
      size: Vector2(300, 150),
    );
  }
}

class LayerGame extends FlameGame {
  late Layer gameLayer;
  late Layer backgroundLayer;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final playerSprite = Sprite(await images.load('layers/player.png'));
    final enemySprite = Sprite(await images.load('layers/enemy.png'));
    final backgroundSprite = Sprite(await images.load('layers/background.png'));

    gameLayer = GameLayer(playerSprite, enemySprite);
    backgroundLayer = BackgroundLayer(backgroundSprite);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    gameLayer.render(canvas);
    backgroundLayer.render(canvas);
  }

  @override
  Color backgroundColor() => const Color(0xFF38607C);
}
