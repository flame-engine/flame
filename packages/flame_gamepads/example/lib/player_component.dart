import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_gamepads/flame_callbacks.dart';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';

class PlayerComponent extends RectangleComponent with GamepadCallbacks {
  final double worldSizeX;
  final double worldSizeY;

  PlayerComponent({required this.worldSizeX, required this.worldSizeY});

  double inputX = 0;
  double inputY = 0;

  static const deadZone = 0.15;
  static const velocity = 150.0;

  @override
  FutureOr<void> onLoad() {
    setColor(Colors.orange);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (inputX != 0.0) {
      position.x = (position.x + inputX * dt * velocity).clamp(
        0,
        worldSizeX - size.x,
      );
    }
    if (inputY != 0.0) {
      position.y = (position.y - inputY * dt * velocity).clamp(
        0,
        worldSizeY - size.y,
      );
    }
  }

  @override
  void onGamepadEvent(NormalizedGamepadEvent event) {
    if (event.axis == GamepadAxis.leftStickX) {
      inputX = event.value.abs() > deadZone ? event.value : 0.0;
    } else if (event.axis == GamepadAxis.leftStickY) {
      inputY = event.value.abs() > deadZone ? event.value : 0.0;
    }
  }
}
