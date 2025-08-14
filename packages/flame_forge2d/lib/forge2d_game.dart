import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/forge2d_world.dart';
import 'package:forge2d/forge2d.dart';

/// The base game class for creating games that uses the Forge2D physics engine.
class Forge2DGame<T extends Forge2DWorld> extends FlameGame<T> {
  Forge2DGame({
    Forge2DWorld? world,
    CameraComponent? camera,
    Vector2? gravity,
    ContactListener? contactListener,
    double zoom = 10,
  }) : super(
         world:
             ((world?..gravity = gravity ?? world.gravity) ??
                     Forge2DWorld(
                       gravity: gravity,
                       contactListener: contactListener,
                     ))
                 as T,
         camera: (camera ?? CameraComponent())..viewfinder.zoom = zoom,
       );

  /// Takes a point in world coordinates and returns it in screen coordinates.
  Vector2 worldToScreen(Vector2 position) {
    return camera.localToGlobal(position);
  }

  /// Takes a point in screen coordinates and returns it in world coordinates.
  ///
  /// Remember that if you are using this for your events you can most of the
  /// time just use `event.localPosition` directly instead.
  Vector2 screenToWorld(Vector2 position) {
    return camera.globalToLocal(position);
  }
}
