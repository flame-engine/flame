import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/joystick.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/painting.dart';

import 'joystick_player.dart';

class JoystickGame extends BaseGame
    with HasDraggableComponents, HasTappableComponents {
  late final JoystickPlayer player;

  @override
  Future<void> onLoad() async {
    debugMode = true;
    final image = await images.load('joystick.png');
    final sheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 6,
      rows: 1,
    );
    final joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: sheet.getSpriteById(1),
        size: Vector2.all(100),
      ),
      background: SpriteComponent(
        sprite: sheet.getSpriteById(0),
        size: Vector2.all(150),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    final buttonSize = Vector2.all(60);
    final flipButton = MarginButtonComponent(
      button: SpriteComponent(
        sprite: sheet.getSpriteById(2),
        size: buttonSize,
      ),
      buttonDown: SpriteComponent(
        sprite: sheet.getSpriteById(4),
        size: buttonSize,
      ),
      margin: const EdgeInsets.only(
        right: 80,
        bottom: 60,
      ),
      onPressed: () => player.renderFlipX = !player.renderFlipX,
    );
    final flopButton = MarginButtonComponent(
      button: SpriteComponent(
        sprite: sheet.getSpriteById(3),
        size: buttonSize,
      ),
      buttonDown: SpriteComponent(
        sprite: sheet.getSpriteById(5),
        size: buttonSize,
      ),
      margin: const EdgeInsets.only(
        right: 140,
        bottom: 60,
      ),
      onPressed: () => player.renderFlipY = !player.renderFlipY,
    );

    player = JoystickPlayer(joystick);
    add(player);
    add(joystick);
    add(flipButton);
    add(flopButton);
  }
}
