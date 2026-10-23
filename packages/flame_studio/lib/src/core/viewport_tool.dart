import 'package:flame/components.dart'
    show Component, PositionComponent, Vector2;
import 'package:flame_studio/src/core/gizmo/gizmo_geometry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What happens when the user interacts with the game view.
enum ViewportTool() {
  /// Pointer events are handled by the game, as if the studio wasn't there.
  interact,

  /// Clicking on the game selects the component under the pointer. The game
  /// does not receive the pointer events.
  select,

  /// Like [select], and dragging the selected component or the handles of its
  /// gizmo moves it.
  move,

  /// Like [select], and dragging the ring of the gizmo rotates the selected
  /// component around its anchor.
  rotate,

  /// Like [select], and dragging the handles of the gizmo scales the selected
  /// component.
  scale,
}

final viewportToolProvider =
    NotifierProvider<ViewportToolController, ViewportTool>(
      ViewportToolController.new,
    );

class ViewportToolController() extends Notifier<ViewportTool> {
  @override
  ViewportTool build() => ViewportTool.interact;

  // ignore: use_setters_to_change_properties
  void use(ViewportTool tool) => state = tool;
}

/// The gizmo handle under the pointer, or being dragged, if any.
final activeGizmoHandleProvider =
    NotifierProvider<ActiveGizmoHandleController, GizmoHandle?>(
      ActiveGizmoHandleController.new,
    );

class ActiveGizmoHandleController() extends Notifier<GizmoHandle?> {
  @override
  GizmoHandle? build() {
    ref.watch(viewportToolProvider);
    return null;
  }

  // ignore: use_setters_to_change_properties
  void set(GizmoHandle? handle) => state = handle;
}

/// The components that can be selected at [canvasPoint], which is in the
/// canvas space of the game rooted at [root], with the topmost first.
List<PositionComponent> selectableComponentsAt(
  Component root,
  Vector2 canvasPoint,
) {
  return root
      .componentsAtPoint(canvasPoint)
      .whereType<PositionComponent>()
      .toList();
}

/// Picks which of the [candidates] to select when clicking on them.
///
/// This is the topmost candidate, unless the [current] selection is one of
/// them, in which case it is the one below it. Clicking repeatedly at the same
/// point thus cycles through all the overlapping components.
PositionComponent? pickNext(
  List<PositionComponent> candidates,
  Component? current,
) {
  if (candidates.isEmpty) {
    return null;
  }
  final index = current is PositionComponent ? candidates.indexOf(current) : -1;
  return candidates[(index + 1) % candidates.length];
}
