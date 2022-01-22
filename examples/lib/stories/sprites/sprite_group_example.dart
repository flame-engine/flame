import 'package:flame/components.dart';
import 'package:flame/game.dart';

enum ButtonState { unpressed, pressed }

class SpriteGroupExample extends FlameGame with HasTappables {
  static const String description = '''
    In this example we show how a `SpriteGroupComponent` can be used to create
    a button which displays different sprites depending on whether it is pressed
    or not.
  ''';

  @override
  Future<void> onLoad() async {
    add(
      ButtonComponent()
        ..position = size / 2
        ..size = Vector2(200, 50)
        ..anchor = Anchor.center,
    );
  }
}

class ButtonComponent extends SpriteGroupComponent<ButtonState>
    with HasGameRef<SpriteGroupExample>, Tappable {
  @override
  Future<void> onLoad() async {
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
