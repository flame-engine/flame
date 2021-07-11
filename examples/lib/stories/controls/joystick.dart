import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/joystick.dart';
import 'package:flutter/material.dart';

import 'joystick_player.dart';

class JoystickGame extends BaseGame with HasDraggableComponents {
  late final JoystickPlayer player;

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
      knob: JoystickElement.sprite(await loadJoystick(1), size: Vector2.all(20),),
      background: JoystickElement.sprite(await loadJoystick(0), size: Vector2.all(40),),
      margin: const EdgeInsets.only(left: 50, bottom: 50),
    );

    player = JoystickPlayer(joystick);
    add(player);
    add(joystick);
  }
}
