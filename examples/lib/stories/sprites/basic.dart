import 'package:flame/components.dart';
import 'package:flame/game.dart';

class BasicSpriteGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await loadSprite('flame.png');
    add(
      SpriteComponent(
        sprite: sprite,
        position: Vector2.all(100),
        size: sprite.srcSize * 2,
      ),
    );
  }
}
