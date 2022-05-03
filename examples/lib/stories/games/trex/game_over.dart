import 'dart:ui';

import 'package:flame/components.dart';

import 'trex_game.dart';

class GameOverPanel extends Component with HasGameRef<TRexGame> {
  bool visible = false;

  @override
  Future<void> onLoad() async {
    add(GameOverText());
    add(GameOverRestart());
  }

  @override
  void renderTree(Canvas canvas) {
    if (visible) {
      super.renderTree(canvas);
    }
  }
}

class GameOverText extends SpriteComponent {
  GameOverText()
      : super(
          size: Vector2(textWidth, textHeight),
          sprite: Sprite(
            TRexGame.spriteImage,
            srcPosition: Vector2(955.0, 26.0),
            srcSize: Vector2(textWidth, textHeight),
          ),
        );

  static const double textWidth = 382.0;
  static const double textHeight = 25.0;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    y = gameSize.y * .25;
    x = (gameSize.x / 2) - textWidth / 2;
  }
}

class GameOverRestart extends SpriteComponent {
  GameOverRestart()
      : super(
          size: Vector2(restartWidth, restartHeight),
          sprite: Sprite(
            TRexGame.spriteImage,
            srcPosition: Vector2.all(2.0),
            srcSize: Vector2(restartWidth, restartHeight),
          ),
        );

  static const double restartWidth = 72.0;
  static const double restartHeight = 64.0;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    y = gameSize.y * .75;
    x = (gameSize.x / 2) - width / 2;
  }
}
