import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_isolate_example/brains/path_finder.dart';
import 'package:flame_isolate_example/brains/worker_overmind.dart';
import 'package:flame_isolate_example/constants.dart';
import 'package:flame_isolate_example/game_map/game_map.dart';
import 'package:flame_isolate_example/objects/colonists_object.dart';
import 'package:flame_isolate_example/terrain/terrain.dart';
import 'package:flame_isolate_example/units/worker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColonistsGame extends FlameGame with KeyboardEvents {
  final PositionComponent _cameraPosition = PositionComponent();
  late final GameMap _currentMap;
  ColonistsGame()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: 400,
          height: 600,
        ),
      );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    camera.follow(_cameraPosition);
    camera.viewfinder.zoom = 0.4;

    await Flame.images.load('bread.png');
    await Flame.images.load('ant_walk.png');
    await Flame.images.load('cheese.png');

    world.add(_currentMap = GameMap());

    _cameraPosition.position = Vector2(
      GameMap.mapSizeX * Constants.tileSize / 2,
      GameMap.mapSizeY * Constants.tileSize / 2,
    );

    add(WorkerOvermind());
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
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    var howMuch = 0.0;
    if (event is KeyDownEvent) {
      howMuch = 1;
    } else if (event is KeyUpEvent) {
      howMuch = 0;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyS) {
      _downForce = howMuch;
    } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
      _upForce = howMuch;
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      _rightForce = howMuch;
    } else if (event.logicalKey == LogicalKeyboardKey.keyA) {
      _leftForce = howMuch;
    } else if (event.logicalKey == LogicalKeyboardKey.numpadAdd &&
        event is KeyDownEvent) {
      camera.viewfinder.zoom = min(
        camera.viewfinder.zoom + 0.1,
        5,
      );
    } else if (event.logicalKey == LogicalKeyboardKey.numpadSubtract &&
        event is KeyDownEvent) {
      camera.viewfinder.zoom = max(
        camera.viewfinder.zoom - 0.1,
        0.1,
      );
    }
    return super.onKeyEvent(event, keysPressed);
  }

  final direction = Vector2(0, 0);

  @override
  void update(double dt) {
    super.update(dt);
    direction.setValues(_rightForce - _leftForce, _downForce - _upForce);
    final step = direction..scale(cameraSpeed * dt * 4);
    _cameraPosition.position += step;
  }

  PathFinderData get pathFinderData => _currentMap.pathFinderData;

  Set<Worker> get workers => _currentMap.workers;

  List<ColonistsObject> get worldObjects => _currentMap.worldObjects;
}
