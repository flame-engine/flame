import 'package:flame/game.dart';
import 'package:flame_studio/src/core/settings.dart';
import 'package:flutter/widgets.dart';

class GameController {
  GameController(this._onChange);

  static GameController of(BuildContext context) {
    return Settings.of(context).controller;
  }

  final void Function() _onChange;

  Game? _game;
  void setGame(Game? game) => _game = game;

  bool get isPaused => _game?.paused ?? false;

  void pauseGame() {
    _game!.pauseEngine();
    _notifyListeners();
  }

  void resumeGame() {
    _game!.resumeEngine();
    _notifyListeners();
  }

  void _notifyListeners() => _onChange();
}
