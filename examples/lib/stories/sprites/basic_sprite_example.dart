import 'package:flame/components.dart';
import 'package:flame/game.dart';

class BasicSpriteExample extends FlameGame {
  static const String description = '''
    In this example we load a sprite from the assets folder and put it into a
    `SpriteComponent`.
  ''';

  @override
  Future<void> onLoad() async {
    final sprite = await loadSprite('flame.png');
    add(
      SpriteComponent(
        sprite: sprite,
        position: size / 2,
        size: sprite.srcSize * 2,
        anchor: Anchor.center,
      ),
    );
  }
}
