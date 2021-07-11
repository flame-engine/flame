import 'package:flame/game.dart';
import 'package:flame_example/stories/controls/joystick.dart';
import 'package:flutter/material.dart';


void main() async {
  runApp(GameWidget(game: JoystickGame()));
}
