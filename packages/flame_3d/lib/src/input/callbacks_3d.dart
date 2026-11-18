import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/src/input/events_3d.dart';

/// Mixin enabling an [Object3D] to receive 3D tap events from
/// `PointerRouter3D`.
mixin TapCallbacks3D on Object3D {
  /// Invoked when a pointer presses down on this object (or a descendant).
  void onTapDown3D(TapDownEvent3D event) {}

  /// Invoked when a pointer releases over this object after [onTapDown3D].
  void onTapUp3D(TapUpEvent3D event) {}

  /// Invoked when an active tap on this object is cancelled.
  void onTapCancel3D(TapCancelEvent3D event) {}
}

/// Mixin enabling an [Object3D] to receive 3D hover enter, move, and exit
/// events from `PointerRouter3D`.
mixin HoverCallbacks3D on Object3D {
  /// Invoked when a hover ray first intersects this object (or a descendant).
  void onHoverEnter3D(HoverEnterEvent3D event) {}

  /// Invoked when a hover ray moves while remaining over this object.
  void onHoverMove3D(HoverMoveEvent3D event) {}

  /// Invoked when the hover ray leaves this object.
  void onHoverExit3D(HoverExitEvent3D event) {}
}

/// Mixin enabling an [Object3D] to receive 3D ray-plane or 1D axis-constrained
/// drag events from `PointerRouter3D`.
mixin DragCallbacks3D on Object3D {
  /// World-space normal of the drag plane passing through the initial grab
  /// point. When `null`, `PointerRouter3D` falls back to its
  /// `defaultDragNormal` or the active camera's view plane normal.
  Vector3? dragPlaneNormal;

  /// Optional world-space 1D translation axis (for example `Vector3(1, 0, 0)`
  /// for a 3D translate gizmo arrow). When non-null, pointer motion is
  /// projected strictly onto the line through the grab point along this axis.
  Vector3? dragAxisConstraint;

  /// Invoked when a drag starts on this object (or a descendant).
  void onDragStart3D(DragStartEvent3D event) {}

  /// Invoked as the dragged pointer moves in 3D space.
  void onDragUpdate3D(DragUpdateEvent3D event) {}

  /// Invoked when an active drag on this object finishes or is cancelled.
  void onDragEnd3D(DragEndEvent3D event) {}
}
