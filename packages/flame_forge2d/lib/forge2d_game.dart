import 'package:flame/game.dart';
import 'package:flame_forge2d/world_contact_listener.dart';
import 'package:forge2d/forge2d.dart';

class Forge2DGame extends FlameGame {
  Forge2DGame({
    Vector2? gravity,
    double zoom = defaultZoom,
    Camera? camera,
    ContactListener? contactListener,
  })  : world = World(gravity ?? defaultGravity),
        super(camera: camera ?? Camera()) {
    this.camera.zoom = zoom;
    world.setContactListener(contactListener ?? WorldContactListener());
  }

  static final Vector2 defaultGravity = Vector2(0, 10.0);

  static const double defaultZoom = 10.0;

  final World world;

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

  Vector2 screenToFlameWorld(Vector2 position) {
    return screenToWorld(position)..y *= -1;
  }
}
