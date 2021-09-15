import 'package:flame/components.dart';
import 'package:flame/game.dart';

enum ButtonState { unpressed, pressed }

class ButtonComponent extends SpriteGroupComponent<ButtonState>
    with HasGameRef<SpriteGroupExample>, Tappable {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final pressedSprite = await gameRef.loadSprite(
      'buttons.png',
      srcPosition: Vector2(0, 20),
      srcSize: Vector2(60, 20),
    );
    final unpressedSprite = await gameRef.loadSprite(
      'buttons.png',
      srcSize: Vector2(60, 20),
    );

    sprites = {
      ButtonState.pressed: pressedSprite,
      ButtonState.unpressed: unpressedSprite,
    };

    current = ButtonState.unpressed;
  }

  @override
  bool onTapDown(_) {
    current = ButtonState.pressed;
    return true;
  }

  @override
  bool onTapUp(_) {
    current = ButtonState.unpressed;
    return true;
  }

  @override
  bool onTapCancel() {
    current = ButtonState.unpressed;
    return true;
  }
}

class SpriteGroupExample extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      ButtonComponent()
        ..position = Vector2(100, 100)
        ..size = Vector2(200, 50),
    );
  }
}
