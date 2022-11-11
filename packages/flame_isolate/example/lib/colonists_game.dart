import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_isolates_example/brains/path_finder.dart';
import 'package:flutter_isolates_example/brains/worker_overmind.dart';
import 'package:flutter_isolates_example/constants.dart';
import 'package:flutter_isolates_example/game_map/game_map.dart';
import 'package:flutter_isolates_example/objects/colonists_object.dart';
import 'package:flutter_isolates_example/terrain/terrain.dart';
import 'package:flutter_isolates_example/units/worker.dart';

class ColonistsGame extends FlameGame with HasTappables, KeyboardEvents {
  final PositionComponent _cameraPos = PositionComponent();
  late final GameMap _currentMap;
  late final WorkerOvermind workerOvermind;

  @override
  Future onLoad() async {
    await Flame.images.load('bread.png');
    await Flame.images.load('worker.png');
    await Flame.images.load('cheese.png');

    add(_currentMap = GameMap());

    camera.followComponent(_cameraPos);
    camera.zoom = 0.4;
    _cameraPos.position = Vector2(
      GameMap.mapSizeX * Constants.tileSize / 2,
      GameMap.mapSizeY * Constants.tileSize / 2,
    );

    add(workerOvermind = WorkerOvermind());

    super.onLoad();
  }

  Terrain tileAtPosition(int x, int y) {
    return _currentMap.tileAtPosition(x, y);
  }

  static const double cameraSpeed = 200;

  double _downForce = 0;
  double _upForce = 0;
  double _rightForce = 0;
  double _leftForce = 0;

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    var howMuch = 0.0;
    if (event is RawKeyDownEvent) {
      howMuch = 1;
    } else if (event is RawKeyUpEvent) {
      howMuch = 0;
    }

    if (event.data.logicalKey == LogicalKeyboardKey.keyS) {
      _downForce = howMuch;
    } else if (event.data.logicalKey == LogicalKeyboardKey.keyW) {
      _upForce = howMuch;
    } else if (event.data.logicalKey == LogicalKeyboardKey.keyD) {
      _rightForce = howMuch;
    } else if (event.data.logicalKey == LogicalKeyboardKey.keyA) {
      _leftForce = howMuch;
    } else if (event.data.logicalKey == LogicalKeyboardKey.numpadAdd &&
        event is RawKeyDownEvent) {
      camera.zoom = min(camera.zoom + 0.1, 5);
    } else if (event.data.logicalKey == LogicalKeyboardKey.numpadSubtract &&
        event is RawKeyDownEvent) {
      camera.zoom = max(camera.zoom - 0.1, 0.1);
    }
    return super.onKeyEvent(event, keysPressed);
  }

  final direction = Vector2(0, 0);

  @override
  void update(double dt) {
    direction.setValues(_rightForce - _leftForce, _downForce - _upForce);
    final step = direction..scale(cameraSpeed * dt * 4);
    _cameraPos.position += step;
    super.update(dt);
  }

  PathFinderData get pathFinderData => _currentMap.pathFinderData;

  Set<Worker> get workers => _currentMap.workers;

  List<ColonistsObject> get worldObjects => _currentMap.worldObjects;
}
