import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/forge2d_world.dart';
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
  // TODO(spydon): Use a meterToPixels constant instead for rendering (see #
  final double _initialZoom;
  late CameraComponent cameraComponent;

  @override
  FutureOr<void> onLoad() async {
    cameraComponent = CameraComponent(world: world)
      ..viewfinder.zoom = _initialZoom;
    add(world);
    add(cameraComponent);
  }
}
