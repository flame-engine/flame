import 'dart:ui';

import 'package:flame/components.dart';
import 'package:trex_game/trex_game.dart';

class GameOverPanel extends Component {
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

class GameOverText extends SpriteComponent with HasGameReference<TRexGame> {
  GameOverText() : super(size: Vector2(382, 25), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      game.spriteImage,
      srcPosition: Vector2(955.0, 26.0),
      srcSize: size,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    x = size.x / 2;
    y = size.y * .25;
  }
}

class GameOverRestart extends SpriteComponent with HasGameReference<TRexGame> {
  GameOverRestart() : super(size: Vector2(72, 64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      game.spriteImage,
      srcPosition: Vector2.all(2.0),
      srcSize: size,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    x = size.x / 2;
    y = size.y * .75;
  }
}
