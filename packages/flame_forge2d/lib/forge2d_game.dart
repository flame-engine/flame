import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/contact_events_dispatcher.dart';
import 'package:flame_forge2d/forge2d_viewfinder.dart';
import 'package:flame_forge2d/forge2d_world.dart';
import 'package:forge2d/forge2d.dart' show initializeForge2D;

/// The base game class for creating games that uses the Forge2D physics engine.
class Forge2DGame<T extends Forge2DWorld> extends FlameGame<T> {
  /// Creates a game with a [Forge2DWorld].
  ///
  /// The world is measured in meters and rendered with [metersToPixels]
  /// pixels per meter, see [Forge2DViewfinder]. If you pass your own [camera]
  /// its viewfinder is replaced with a [Forge2DViewfinder], unless it already
  /// is one, in which case [metersToPixels] is applied to it.
  ///
  /// [contactEventsDispatcher] is only used for the world that this
  /// constructor creates, so pass it to the [Forge2DWorld] itself when you
  /// provide a [world].
  Forge2DGame({
    Forge2DWorld? world,
    CameraComponent? camera,
    Vector2? gravity,
    ContactEventsDispatcher? contactEventsDispatcher,
    double metersToPixels = Forge2DViewfinder.defaultMetersToPixels,
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
         camera: camera ?? CameraComponent(),
       ) {
    final viewfinder = this.camera.viewfinder;
    if (viewfinder is Forge2DViewfinder) {
      viewfinder.metersToPixels = metersToPixels;
    } else {
      this.camera.viewfinder = Forge2DViewfinder(
        metersToPixels: metersToPixels,
      );
    }
  }

  /// The number of pixels that one meter of the physics world is rendered as.
  ///
  /// See [Forge2DViewfinder.metersToPixels].
  double get metersToPixels => _viewfinder.metersToPixels;
  set metersToPixels(double value) => _viewfinder.metersToPixels = value;

  Forge2DViewfinder get _viewfinder => camera.viewfinder as Forge2DViewfinder;

  /// Initializes Forge2D and then loads the game.
  ///
  /// On the web this is what loads the Box2D WebAssembly module, and no
  /// physics world can be created before it has completed, which is why the
  /// world of a [Forge2DWorld] is created lazily.
  ///
  /// Subclasses that override this **must** await `super.onLoad()` before
  /// they create any bodies, or the game will throw on the web.
  @override
  Future<void> onLoad() async {
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
