import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_gamepads/flame_gamepads.dart';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';

void main() {
  runApp(GameWidget(game: GamepadsGame()));
}

class GamepadsGame extends FlameGame {
  PlayerComponent? player;

  static const worldSizeX = 16.0 * 28;
  static const worldSizeY = 16.0 * 14;

  GamepadsGame()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: worldSizeX,
          height: worldSizeY,
        ),
      );

  @override
  Future<void> onLoad() async {
    camera.viewfinder.zoom = 0.5;
    camera.moveTo(Vector2(worldSizeX / 2, worldSizeY / 2));

    player = PlayerComponent(worldSizeX: worldSizeX, worldSizeY: worldSizeY)
      ..position = Vector2(5 * 16, 5 * 16)
      ..size = Vector2(16, 16);
    world.addAll([
      RectangleComponent()
        ..size = Vector2(worldSizeX, worldSizeY)
        ..setColor(Colors.lightGreen[800]!),
      TextComponent(text: 'Use left thumbstick on your gamepad to move player')
        ..position = Vector2(worldSizeX / 2, worldSizeY + 10)
        ..scale = Vector2.all(0.7)
        ..anchor = Anchor.topCenter,
      player!,
    ]);
  }
}

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

  /// This method is provided via GamepadCallbacks mixin from
  /// flame_gamepads package.
  @override
  void onGamepadEvent(NormalizedGamepadEvent event) {
    if (event.axis == GamepadAxis.leftStickX) {
      inputX = event.value.abs() > deadZone ? event.value : 0.0;
    } else if (event.axis == GamepadAxis.leftStickY) {
      inputY = event.value.abs() > deadZone ? event.value : 0.0;
    }
  }
}
