import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';
import 'package:meta/meta.dart';

/// [WorldRoute] is a class that allows setting the world that a camera is
/// looking at.
class WorldRoute extends Route {
  /// A world route that uses the specified [builder]. This builder will be
  /// registered with the Game's map of world builders when this route is
  /// first activated.
  ///
  /// The [camera] parameter is optional and can be used to set the camera
  /// that will be used to render the world, if not provided the default camera
  /// will be used.
  WorldRoute(this.builder, {this.camera, super.maintainState}) : super(null);

  final World Function() builder;
  final CameraComponent? camera;
  late World? _previousWorld;
  World? world;

  Game get game => findGame()!;

  @override
  String get name => super.name!;

  @override
  World build() {
    if (!maintainState) {
      world = builder();
      return world!;
    } else {
      return world ??= builder();
    }
  }

  @internal
  @override
  void didPush(Route? previousRoute) => onPush(previousRoute);

  @mustCallSuper
  @override
  void onPush(Route? previousRoute) {
    assert(
      camera != null || game is FlameGame,
      'You need to either provide a camera or use a FlameGame to use the '
      'WorldRoute',
    );
    if (camera != null) {
      _previousWorld = camera?.world;
      camera?.world = build();
    } else {
      _previousWorld = (game as FlameGame).world;
      (game as FlameGame).world = build();
    }
  }

  @mustCallSuper
  @override
  void onPop(Route nextRoute) {
    if (camera != null) {
      camera?.world = _previousWorld;
    } else {
      (game as FlameGame).world = _previousWorld ?? World();
    }
  }

  @override
  @internal
  void addRenderEffect(Decorator effect) => UnimplementedError(
    'WorldRoute does not support render effects',
  );

  @override
  @internal
  void removeRenderEffect() => UnimplementedError(
    'WorldRoute does not support render effects',
  );
}
