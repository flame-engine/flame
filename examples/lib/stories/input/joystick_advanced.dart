import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import 'joystick_player.dart';

class JoystickAdvancedGame extends FlameGame
    with HasDraggableComponents, HasTappableComponents {
  late final JoystickPlayer player;
  late final JoystickComponent joystick;
  late final TextComponent speedText;
  late final TextComponent directionText;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final image = await images.load('joystick.png');
    final sheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 6,
      rows: 1,
    );
    joystick = JoystickComponent(
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
    player = JoystickPlayer(joystick);

    final buttonSize = Vector2.all(80);
    // A button with margin from the edge of the viewport that flips the
    // rendering of the player on the X-axis.
    final flipButton = HudButtonComponent(
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
      onPressed: player.flipHorizontally,
    );

    // A button with margin from the edge of the viewport that flips the
    // rendering of the player on the Y-axis.
    final flopButton = HudButtonComponent(
      button: SpriteComponent(
        sprite: sheet.getSpriteById(3),
        size: buttonSize,
      ),
      buttonDown: SpriteComponent(
        sprite: sheet.getSpriteById(5),
        size: buttonSize,
      ),
      margin: const EdgeInsets.only(
        right: 160,
        bottom: 60,
      ),
      onPressed: player.flipVertically,
    );

    final rotateEffect = RotateEffect(
      angle: 0,
      curve: Curves.bounceOut,
      isAlternating: true,
      speed: 2,
    );
    final rng = Random();
    // A button, created from a shape, that adds a rotation effect to the player
    // when it is pressed.
    final shapeButton = HudButtonComponent(
      button: Circle(radius: 35).toComponent(paint: BasicPalette.white.paint()),
      buttonDown: Rectangle(size: buttonSize)
          .toComponent(paint: BasicPalette.blue.paint()),
      margin: const EdgeInsets.only(
        right: 85,
        bottom: 150,
      ),
      onPressed: () => player.add(
        rotateEffect..angle = 8 * rng.nextDouble(),
      ),
    );

    final _regularTextConfig = TextPaintConfig(color: BasicPalette.white.color);
    final _regular = TextPaint(config: _regularTextConfig);
    speedText = TextComponent(
      'Speed: 0',
      textRenderer: _regular,
    )..isHud = true;
    directionText = TextComponent(
      'Direction: idle',
      textRenderer: _regular,
    )..isHud = true;

    final speedWithMargin = HudMarginComponent(
      margin: const EdgeInsets.only(
        top: 80,
        left: 80,
      ),
    )..add(speedText);

    final directionWithMargin = HudMarginComponent(
      margin: const EdgeInsets.only(
        top: 110,
        left: 80,
      ),
    )..add(directionText);

    add(player);
    add(joystick);
    add(flipButton);
    add(flopButton);
    add(shapeButton);
    add(speedWithMargin);
    add(directionWithMargin);
  }

  @override
  void update(double dt) {
    super.update(dt);
    speedText.text = 'Speed: ${(joystick.intensity * player.maxSpeed).round()}';
    final direction =
        joystick.direction.toString().replaceAll('JoystickDirection.', '');
    directionText.text = 'Direction: $direction';
  }
}
