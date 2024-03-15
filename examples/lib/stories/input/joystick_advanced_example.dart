import 'dart:math';

import 'package:examples/stories/input/joystick_player.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class JoystickAdvancedExample extends FlameGame with HasCollisionDetection {
  static const String description = '''
    In this example we showcase how to use the joystick by creating 
    `SpriteComponent`s that serve as the joystick's knob and background.
    We also showcase the `HudButtonComponent` which is a button that has its
    position defined by margins to the edges, which can be useful when making
    controller buttons.\n\n
    Steer the player by using the joystick and flip and rotate it by pressing
    the buttons.
  ''';

  JoystickAdvancedExample()
      : super(
          camera: CameraComponent.withFixedResolution(width: 1200, height: 800),
        );

  late final JoystickPlayer player;
  late final JoystickComponent joystick;
  late final TextComponent speedText;
  late final TextComponent directionText;

  @override
  Future<void> onLoad() async {
    final image = await images.load('joystick.png');
    final sheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 6,
      rows: 1,
    );
    world.add(ScreenHitbox());
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

    final rng = Random();
    // A button, created from a shape, that adds a rotation effect to the player
    // when it is pressed.
    final shapeButton = HudButtonComponent(
      button: CircleComponent(radius: 35),
      buttonDown: RectangleComponent(
        size: buttonSize,
        paint: BasicPalette.blue.paint(),
      ),
      margin: const EdgeInsets.only(
        right: 85,
        bottom: 150,
      ),
      onPressed: () => player.add(
        RotateEffect.by(
          8 * rng.nextDouble(),
          EffectController(
            duration: 1,
            reverseDuration: 1,
            curve: Curves.bounceOut,
          ),
        ),
      ),
    );

    // A button, created from a shape, that adds a scale effect to the player
    // when it is pressed.
    final buttonComponent = ButtonComponent(
      button: RectangleComponent(
        size: Vector2(185, 50),
        paint: Paint()
          ..color = Colors.orange
          ..style = PaintingStyle.stroke,
      ),
      buttonDown: RectangleComponent(
        size: Vector2(185, 50),
        paint: BasicPalette.magenta.paint(),
      ),
      position: Vector2(20, size.y - 280),
      onPressed: () => player.add(
        ScaleEffect.by(
          Vector2.all(1.5),
          EffectController(duration: 1.0, reverseDuration: 1.0),
        ),
      ),
    );

    final buttonSprites = await images.load('buttons.png');
    final buttonSheet = SpriteSheet.fromColumnsAndRows(
      image: buttonSprites,
      columns: 1,
      rows: 2,
    );

    // A sprite button, created from a shape, that adds a opacity effect to the
    // player when it is pressed.
    final spriteButtonComponent = SpriteButtonComponent(
      button: buttonSheet.getSpriteById(0),
      buttonDown: buttonSheet.getSpriteById(1),
      position: Vector2(20, size.y - 360),
      size: Vector2(185, 50),
      onPressed: () => player.add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.5, reverseDuration: 0.5),
        ),
      ),
    );

    final regular = TextPaint(
      style: TextStyle(color: BasicPalette.white.color),
    );
    speedText = TextComponent(
      text: 'Speed: 0',
      textRenderer: regular,
    );
    directionText = TextComponent(
      text: 'Direction: idle',
      textRenderer: regular,
    );

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

    world.add(player);
    camera.viewport.addAll([
      joystick,
      flipButton,
      flopButton,
      buttonComponent,
      spriteButtonComponent,
      shapeButton,
      speedWithMargin,
      directionWithMargin,
    ]);
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
