import 'package:flame/game.dart';
import 'package:forge2d/forge2d.dart';

import 'contact_callbacks.dart';
import 'forge2d_camera.dart';

class Forge2DGame extends FlameGame {
  Forge2DGame({
    Vector2? gravity,
    double zoom = defaultZoom,
    Camera? camera,
  })  : world = World(gravity ?? defaultGravity),
        super(camera: camera ?? Forge2DCamera()) {
    this.camera.zoom = zoom;
    world.setContactListener(WorldContactListener());
  }

  static final Vector2 defaultGravity = Vector2(0, -10.0);

  static const double defaultZoom = 10.0;

  final World world;

  /// The camera translates the coordinate space after the viewport is applied.
  @override
  Forge2DCamera get camera => super.camera as Forge2DCamera;

  @override
  void update(double dt) {
    super.update(dt);
    world.stepDt(dt);
  }

  Vector2 worldToScreen(Vector2 position) {
    return projector.projectVector(position);
  }

  Vector2 screenToWorld(Vector2 position) {
    return projector.unprojectVector(position);
  }
}
