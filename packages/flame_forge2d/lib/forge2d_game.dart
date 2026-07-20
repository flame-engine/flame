import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/contact_events_dispatcher.dart';
import 'package:flame_forge2d/forge2d_world.dart';
import 'package:forge2d/forge2d.dart' show initializeForge2D;

/// The base game class for creating games that uses the Forge2D physics engine.
class Forge2DGame<T extends Forge2DWorld> extends FlameGame<T> {
  /// Creates a game with a [Forge2DWorld].
  ///
  /// [contactEventsDispatcher] is only used for the world that this
  /// constructor creates, so pass it to the [Forge2DWorld] itself when you
  /// provide a [world].
  Forge2DGame({
    Forge2DWorld? world,
    CameraComponent? camera,
    Vector2? gravity,
    ContactEventsDispatcher? contactEventsDispatcher,
    double zoom = 10,
  }) : assert(
         world == null || contactEventsDispatcher == null,
         'contactEventsDispatcher is ignored when a world is provided, pass '
         'it to the Forge2DWorld constructor instead',
       ),
       super(
         world:
             ((world?..gravity = gravity ?? world.gravity) ??
                     Forge2DWorld(
                       gravity: gravity,
                       contactEventsDispatcher: contactEventsDispatcher,
                     ))
                 as T,
         camera: (camera ?? CameraComponent())..viewfinder.zoom = zoom,
       );

  @override
  Future<void> onLoad() async {
    // Forge2D has to be initialized before any physics world is created,
    // which on the web means loading the Box2D WebAssembly module. The
    // world of a [Forge2DWorld] is created lazily so that this can happen
    // first.
    await initializeForge2D();
    await super.onLoad();
  }

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
