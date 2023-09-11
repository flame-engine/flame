import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/extensions.dart';
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

  //@override
  //Vector2 get size => cameraComponent.visibleWorldRect.toVector2();

  // Should be removed later and use world.localToParent instead.
  Vector2 worldToScreen(Vector2 position) {
    return world.localToParent(position, camera: cameraComponent)!;
  }

  // Should be removed later and use world.parentToLocal instead.
  Vector2 screenToWorld(Vector2 position) {
    return world.parentToLocal(position, camera: cameraComponent)!;
  }
}
