import 'package:flame/game.dart';
import 'package:flame_studio/src/core/settings.dart';
import 'package:flutter/widgets.dart';

class GameController {
  static GameController of(BuildContext context) {
    return Settings.of(context).controller;
  }

  Game? game;
}
