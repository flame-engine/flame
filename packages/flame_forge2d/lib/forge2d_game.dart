import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/forge2d_world.dart';
import 'package:flutter/foundation.dart';
import 'package:forge2d/forge2d.dart';

/// The base game class for creating games that uses the Forge2D physics engine.
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

  Forge2DWorld world;
  CameraComponent cameraComponent = CameraComponent();

  // TODO(spydon): Use a meterToPixels constant instead for rendering.
  // (see #2613)
  final double _initialZoom;

  @override
  @mustCallSuper
  FutureOr<void> onLoad() async {
    cameraComponent
      ..world = world
      ..viewfinder.zoom = _initialZoom;
    add(world);
    add(cameraComponent);
  }

  /// Takes a point in world coordinates and returns it in screen coordinates.
  Vector2 worldToScreen(Vector2 position) {
    return cameraComponent.localToGlobal(position);
  }

  /// Takes a point in screen coordinates and returns it in world coordinates.
  Vector2 screenToWorld(Vector2 position) {
    return cameraComponent.globalToLocal(position);
  }
}
