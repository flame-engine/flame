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
    Forge2DWorld? world,
  })  : _world = (world?..setGravity(gravity)) ??
            Forge2DWorld(
              gravity: gravity,
              contactListener: contactListener,
            ),
        _initialZoom = zoom;

  /// The [Forge2DWorld] that the [cameraComponent] is rendering.
  /// Inside of this world is where all your components should be added.
  Forge2DWorld get world => _world;
  set world(Forge2DWorld newWorld) {
    cameraComponent.world = newWorld;
    _world = newWorld;
  }

  Forge2DWorld _world;

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
    add(cameraComponent);
    add(world);
  }

  /// Takes a point in world coordinates and returns it in screen coordinates.
  Vector2 worldToScreen(Vector2 position) {
    return cameraComponent.localToGlobal(position);
  }

  /// Takes a point in screen coordinates and returns it in world coordinates.
  ///
  /// Remember that if you are using this for your events you can most of the
  /// time just use `event.localPosition` directly instead.
  Vector2 screenToWorld(Vector2 position) {
    return cameraComponent.globalToLocal(position);
  }
}
