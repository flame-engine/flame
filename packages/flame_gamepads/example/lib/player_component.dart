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

  bool get inputActive => inputX.abs() > deadZone || inputY.abs() > deadZone;

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

    if (inputActive) {
      final newPosition =
          position +
          Vector2(
            inputX * dt * velocity,
            -inputY * dt * velocity,
          );
      newPosition.clamp(
        Vector2.zero(),
        Vector2(worldSizeX - size.x, worldSizeY - size.y),
      );
      position = newPosition;
    }
  }

  @override
  void onGamepadEvent(NormalizedGamepadEvent event) {
    if (event.axis == GamepadAxis.leftStickX) {
      inputX = event.value.abs() > deadZone ? event.value : 0;
    } else if (event.axis == GamepadAxis.leftStickY) {
      inputY = event.value.abs() > deadZone ? event.value : 0;
    }
  }
}
