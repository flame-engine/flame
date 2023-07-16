import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/forge2d_world.dart';
import 'package:flutter/cupertino.dart';
import 'package:forge2d/forge2d.dart';

class Forge2DGame extends FlameGame {
  Forge2DGame({
    Vector2? gravity,
    ContactListener? contactListener,
    double zoom = 10,
  })  : world = Forge2DWorld(
          gravity: gravity,
          contactListener: contactListener,
        ),
        _initialZoom = zoom;

  final Forge2DWorld world;
  // TODO(spydon): Use a metersToPixels constant instead for rendering.
  final double _initialZoom;
  late CameraComponent cameraComponent;

  @override
  @mustCallSuper
  FutureOr<void> onLoad() async {
    cameraComponent = CameraComponent(world: world)
      ..viewfinder.zoom = _initialZoom;
    add(cameraComponent);
    add(world);
  }

  Vector2 worldToScreen(Vector2 position) {
    return cameraComponent.viewfinder.position;
  }

  Vector2 screenToWorld(Vector2 position) {
    return cameraComponent.viewfinder.position
      ..clone()
      ..scale(cameraComponent.viewfinder.zoom);
  }
}
