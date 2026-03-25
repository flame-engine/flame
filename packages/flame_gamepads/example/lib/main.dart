import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_gamepads_example/player_component.dart';
import 'package:flutter/material.dart';

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
    camera.viewfinder
      ..zoom = 0.5
      ..anchor = Anchor.topLeft;

    player = PlayerComponent(worldSizeX: worldSizeX, worldSizeY: worldSizeY)
      ..position = Vector2(5*16, 5*16)
      ..size = Vector2(16, 16);
    world.addAll([
      RectangleComponent()
        ..size = Vector2(worldSizeX, worldSizeY)
        ..setColor(Colors.lightGreen[800]!),
      player!,
    ]);
  }
}
