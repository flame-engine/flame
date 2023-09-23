import 'package:examples/stories/input/joystick_player.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/layout.dart';
import 'package:flutter/painting.dart';

class AdvancedButtonExample extends FlameGame {
  static const String description =
      '''The example shows how you can use a button with different states''';

  late final JoystickPlayer player;
  late final JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    final defaultButton = DefaultButton();
    defaultButton.position = Vector2(100, 100);
    defaultButton.size = Vector2(100, 50);
    add(defaultButton);

    defaultButton.add(AlignComponent(
      child: TextComponent(text: 'Defa'),
      alignment: Anchor.center,
    ));

    final disableButton = DisableButton();
    disableButton.isDisabled = true;
    disableButton.position = Vector2(300, 100);
    disableButton.size = Vector2(100, 50);
    add(disableButton);
  }
}

class DefaultButton extends AdvancedButtonComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    defaultSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 255, 0, 1));

    downSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(255, 255, 0, 1));
  }
}

class DisableButton extends AdvancedButtonComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    defaultSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 255, 0, 1));

    disabledSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(100, 100, 100, 1));
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
