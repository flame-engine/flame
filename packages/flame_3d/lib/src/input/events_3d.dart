import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';

/// Base class for 3D pointer, hover, and drag events dispatched by
/// `PointerRouter3D`.
abstract class PointerEvent3D({
  required final int pointerId,
  required final Vector2 localPosition,
  required final Ray worldRay,
  required final Object3D target,
  final RayHit3D? hit,
  int? instanceIndex,
}) {
  final int? _capturedInstanceIndex = instanceIndex;

  /// Picked instance index when [target] (or [hit]'s object) is an
  /// [InstancedGroup3D], or `null` for non-instanced objects.
  int? get instanceIndex {
    if (_capturedInstanceIndex != null) {
      return _capturedInstanceIndex;
    }
    final rayHit = hit;
    if (rayHit != null && rayHit.object is InstancedGroup3D) {
      return rayHit.surfaceIndex;
    }
    return null;
  }

  /// Set to `true` by a callback to stop propagation to ancestor components.
  bool handled = false;
}

/// Fired when a pointer presses down on a 3D object.
class TapDownEvent3D({
  required super.pointerId,
  required super.localPosition,
  required super.worldRay,
  required super.target,
  super.hit,
  super.instanceIndex,
}) extends PointerEvent3D;

/// Fired when a pointer releases over a previously pressed 3D object.
class TapUpEvent3D({
  required super.pointerId,
  required super.localPosition,
  required super.worldRay,
  required super.target,
  super.hit,
  super.instanceIndex,
}) extends PointerEvent3D;

/// Fired when an active 3D tap gesture is cancelled or released off-target.
class TapCancelEvent3D({
  required super.pointerId,
  required super.localPosition,
  required super.worldRay,
  required super.target,
  super.hit,
  super.instanceIndex,
}) extends PointerEvent3D;

/// Fired when a hover pointer enters a 3D object.
class HoverEnterEvent3D({
  required super.pointerId,
  required super.localPosition,
  required super.worldRay,
  required super.target,
  super.hit,
  super.instanceIndex,
}) extends PointerEvent3D;

/// Fired when a hover pointer moves across an already-hovered 3D object.
class HoverMoveEvent3D({
  required super.pointerId,
  required super.localPosition,
  required super.worldRay,
  required super.target,
  super.hit,
  super.instanceIndex,
}) extends PointerEvent3D;

/// Fired when a hover pointer leaves a previously hovered 3D object.
class HoverExitEvent3D({
  required super.pointerId,
  required super.localPosition,
  required super.worldRay,
  required super.target,
  super.hit,
  super.instanceIndex,
}) extends PointerEvent3D;

/// Fired when a 3D drag gesture begins on an [Object3D].
class DragStartEvent3D({
  required super.pointerId,
  required super.localPosition,
  required super.worldRay,
  required super.target,
  required final Vector3 worldPlanePoint,
  Vector3? worldDelta,
  super.hit,
  super.instanceIndex,
}) extends PointerEvent3D {
  /// Incremental world-space change on the drag plane (`(0, 0, 0)` on start).
  final Vector3 worldDelta = worldDelta ?? Vector3.zero();
}

/// Fired on each pointer movement during an active 3D drag gesture.
class DragUpdateEvent3D({
  required super.pointerId,
  required super.localPosition,
  required super.worldRay,
  required super.target,
  required final Vector3 worldPlanePoint,
  required final Vector3 worldDelta,
  super.hit,
  super.instanceIndex,
}) extends PointerEvent3D;

/// Fired when an active 3D drag gesture ends or is cancelled.
class DragEndEvent3D({
  required super.pointerId,
  required super.localPosition,
  required super.worldRay,
  required super.target,
  required final Vector3 worldPlanePoint,
  Vector3? worldDelta,
  final bool wasCancelled = false,
  super.hit,
  super.instanceIndex,
}) extends PointerEvent3D {
  /// Incremental world-space change since the previous drag update.
  final Vector3 worldDelta = worldDelta ?? Vector3.zero();
}
