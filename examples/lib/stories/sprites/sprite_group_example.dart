import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

enum ButtonState { unpressed, pressed }

class SpriteGroupExample extends FlameGame {
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
    with HasGameReference<SpriteGroupExample>, TapCallbacks {
  @override
  Future<void> onLoad() async {
    final pressedSprite = await game.loadSprite(
      'buttons.png',
      srcPosition: Vector2(0, 20),
      srcSize: Vector2(60, 20),
    );
    final unpressedSprite = await game.loadSprite(
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
  void onTapDown(_) {
    current = ButtonState.pressed;
  }

  @override
  void onTapUp(_) {
    current = ButtonState.unpressed;
  }

  @override
  void onTapCancel(_) {
    current = ButtonState.unpressed;
  }
}
