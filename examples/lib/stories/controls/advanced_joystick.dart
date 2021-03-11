import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/joystick.dart';
import 'package:flutter/material.dart';

import 'joystick_player.dart';

class AdvancedJoystickGame extends BaseGame with HasDraggableComponents {
  Future<Sprite> loadJoystick(int idx) async {
    return loadSprite(
      'joystick.png',
      srcPosition: Vector2(idx * 16.0, 0),
      srcSize: Vector2.all(16),
    );
  }

  @override
  Future<void> onLoad() async {
    final joystick = JoystickComponent(
      gameRef: this,
      directional: JoystickDirectional(
        background: JoystickElement.sprite(await loadJoystick(0)),
        knob: JoystickElement.sprite(await loadJoystick(1)),
      ),
      actions: [
        JoystickAction(
          actionId: 1,
          margin: const EdgeInsets.all(50),
          action: JoystickElement.sprite(await loadJoystick(2)),
          actionPressed: JoystickElement.sprite(await loadJoystick(4)),
        ),
        JoystickAction(
          actionId: 2,
          action: JoystickElement.sprite(await loadJoystick(3)),
          actionPressed: JoystickElement.sprite(await loadJoystick(5)),
          margin: const EdgeInsets.only(
            right: 50,
            bottom: 120,
          ),
        ),
        JoystickAction(
          actionId: 3,
          margin: const EdgeInsets.only(bottom: 50, right: 120),
          enableDirection: true,
          color: const Color(0xFFFF00FF),
          opacityBackground: 0.1,
          opacityKnob: 0.9,
        ),
      ],
    );

    final player = JoystickPlayer();
    joystick.addObserver(player);

    add(player);
    add(joystick);
  }
}
