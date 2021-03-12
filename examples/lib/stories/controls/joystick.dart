import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/joystick.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

import 'joystick_player.dart';

class JoystickGame extends BaseGame with HasDraggableComponents {
  @override
  Future<void> onLoad() async {
    final joystick = JoystickComponent(
      gameRef: this,
      directional: JoystickDirectional(),
      actions: [
        JoystickAction(
          actionId: 1,
          margin: const EdgeInsets.all(50),
          color: const Color(0xFF0000FF),
        ),
        JoystickAction(
          actionId: 2,
          color: const Color(0xFF00FF00),
          margin: const EdgeInsets.only(
            right: 50,
            bottom: 120,
          ),
        ),
        JoystickAction(
          actionId: 3,
          margin: const EdgeInsets.only(bottom: 50, right: 120),
          enableDirection: true,
        ),
      ],
    );

    final player = JoystickPlayer();
    joystick.addObserver(player);

    add(player);
    add(joystick);
  }
}
