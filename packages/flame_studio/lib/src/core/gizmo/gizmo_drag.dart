import 'package:flame/components.dart' show Vector2;

/// A change to a component made by dragging a handle of its gizmo.
///
/// Drags are measured in the canvas space of the game. What the drag needs to
/// know about the component is captured when it starts, so that it keeps
/// following the pointer even when the drag moves the camera, for example a
/// camera that follows the component.
abstract interface class GizmoDrag() {
  /// Applies the drag, where [canvasDelta] is the distance between the start
  /// of the drag and the current pointer position in canvas space.
  ///
  /// When [snap] is true, the result is rounded to convenient values.
  void update(Vector2 canvasDelta, {bool snap = false});

  /// Restores the component to how it was when the drag started.
  void cancel();
}
