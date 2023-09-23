import 'package:examples/stories/input/joystick_player.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

class AdvancedButtonExample extends FlameGame {
  static const String description = '''
    In this example we showcase how to use the joystick by creating simple
    `CircleComponent`s that serve as the joystick's knob and background.
    Steer the player by using the joystick.
  ''';

  late final JoystickPlayer player;
  late final JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    final defaultButton = DefaultButton();
    add(defaultButton);
  }
}

class DefaultButton extends AdvancedButtonComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(100, 50);

    defaultSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 255, 0, 1));
  }
}

class RoundedRectComponent extends PositionComponent with HasPaint {
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        0,
        0,
        width,
        height,
        topLeft: Radius.circular(height),
        topRight: Radius.circular(height),
        bottomRight: Radius.circular(height),
        bottomLeft: Radius.circular(height),
      ),
      paint,
    );
  }
}
