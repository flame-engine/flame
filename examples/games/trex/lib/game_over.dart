import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:trex_game/trex_game.dart';

class GameOverPanel extends Component {
  bool visible = false;

  @override
  Future<void> onLoad() async {
    add(GameOverText());
    add(GameOverRestart());
  }

  @override
  void renderTree(RenderContext context) {
    if (visible) {
      super.renderTree(context);
    }
  }
}

class GameOverText extends SpriteComponent with HasGameRef<TRexGame> {
  GameOverText() : super(size: Vector2(382, 25), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      gameRef.spriteImage,
      srcPosition: Vector2(955.0, 26.0),
      srcSize: size,
    );
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    x = gameSize.x / 2;
    y = gameSize.y * .25;
  }
}

class GameOverRestart extends SpriteComponent with HasGameRef<TRexGame> {
  GameOverRestart() : super(size: Vector2(72, 64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      gameRef.spriteImage,
      srcPosition: Vector2.all(2.0),
      srcSize: size,
    );
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    x = gameSize.x / 2;
    y = gameSize.y * .75;
  }
}
