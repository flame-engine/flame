import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/painting.dart';

import 'joystick_player.dart';

class JoystickGame extends FlameGame with HasDraggableComponents {
  late final JoystickPlayer player;
  late final JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final knobPaint = BasicPalette.blue.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.blue.withAlpha(100).paint();
    joystick = JoystickComponent(
      knob: Circle(radius: 30).toComponent(paint: knobPaint),
      background: Circle(radius: 100).toComponent(paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    player = JoystickPlayer(joystick);

    add(player);
    add(joystick);
  }
}
