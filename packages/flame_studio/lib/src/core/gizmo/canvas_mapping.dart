import 'package:flame/camera.dart' show Viewfinder, Viewport;
import 'package:flame/components.dart'
    show
        CameraComponent,
        Component,
        CoordinateTransform,
        PositionComponent,
        Vector2,
        World;
import 'package:flame/game.dart' show FlameGame;

/// Converts [point] from the local coordinate space of [component] into the
/// canvas space of the game, which is in logical pixels relative to the
/// top-left corner of the game widget.
///
/// This follows the same transforms that are applied when rendering the
/// component. A [World] is only rendered through the cameras that look at it,
/// so for components inside of a world the [camera] to map through must be
/// given; see [camerasFor].
///
/// Returns null when the point can't be mapped, for example when the component
/// is in a world that [camera] doesn't look at.
Vector2? localToCanvas(
  Component component,
  Vector2 point, {
  CameraComponent? camera,
}) {
  var result = point.clone();
  final visitedWorlds = <World>{};
  Component? current = component;
  while (current != null) {
    switch (current) {
      case PositionComponent():
        result = current.positionOf(result);
      case World():
        if (camera == null ||
            camera.world != current ||
            !visitedWorlds.add(current)) {
          return null;
        }
        result = camera.localToGlobal(result);
        current = camera;
      case Viewfinder(parent: final CameraComponent parentCamera):
        // The viewfinder is rendered within the viewport of its camera.
        result = parentCamera.localToGlobal(result);
        current = parentCamera;
      case Viewport(parent: final CameraComponent parentCamera):
        result = current.localToGlobal(result);
        current = parentCamera;
      case final CoordinateTransform transform:
        final parentPoint = transform.localToParent(result);
        if (parentPoint == null) {
          return null;
        }
        result = parentPoint;
      default:
    }
    current = current.parent;
  }
  return result;
}

/// The cameras through which [component] is rendered.
///
/// Contains a single null value when the component is not in a [World], as it
/// is rendered without going through a camera. Only cameras that are direct
/// children of the game are considered.
List<CameraComponent?> camerasFor(Component component) {
  final world = component.ancestors(includeSelf: true).whereType<World>();
  if (world.isEmpty) {
    return const [null];
  }
  final game = component.findGame();
  if (game is! FlameGame) {
    return const [];
  }
  return game.children
      .whereType<CameraComponent>()
      .where((camera) => camera.world == world.first)
      .toList();
}
